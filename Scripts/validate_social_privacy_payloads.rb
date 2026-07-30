#!/usr/bin/env ruby
# frozen_string_literal: true
require "json"
require "optparse"

class PayloadError < StandardError
  attr_reader :code
  def initialize(code, message)
    @code = code
    super(message)
  end
end

class PrivacyPayloadValidator
  FORBIDDEN_KEY = /(?:prediction|outcome|note|prompt|group(?:_name)?|handle|email|invite|token|credential|password|secret|location|latitude|longitude|coordinate|url|uri|request|response|body|text|content|message)/i
  SECRET_VALUE = /(?:\A(?:sk|pk|api|auth|bearer)[_-]|-----BEGIN(?: [A-Z]+)? PRIVATE KEY-----|eyJ[a-zA-Z0-9_-]{10,}\.)/i
  URL_VALUE = %r{(?:https?://|www\.)}i
  EMAIL_VALUE = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i
  COORDINATE_VALUE = /-?(?:[1-8]?\d(?:\.\d{3,})?|90(?:\.0+)?)[,_ ]+-?(?:1[0-7]\d|[1-9]?\d)(?:\.\d{3,})?/
  def initialize(policy); @policy = policy; @opaque_id = Regexp.new(policy.fetch("opaque_id_pattern")); @max_string = policy.fetch("max_string_length"); end
  def validate(type, payload)
    fail_with("INVALID_PAYLOAD", "payload must be an object") unless payload.is_a?(Hash)
    scan_values(payload)
    case type
    when "product_telemetry" then validate_telemetry(payload, false)
    when "operational_telemetry" then validate_telemetry(payload, true)
    when "apns_push" then validate_push(payload)
    else fail_with("UNKNOWN_TYPE", "type #{type.inspect} is not allowed")
    end
  end
  private
  def fail_with(code, message); raise PayloadError.new(code, message); end
  def scan_values(value, path = "payload")
    case value
    when Hash
      value.each { |key, child| fail_with("FORBIDDEN_FIELD", "#{path}.#{key} is prohibited") if key.match?(FORBIDDEN_KEY); scan_values(child, "#{path}.#{key}") }
    when Array then value.each_with_index { |child, index| scan_values(child, "#{path}[#{index}]") }
    when String
      fail_with("OVERSIZED_VALUE", "#{path} exceeds #{@max_string} characters") if value.length > @max_string
      fail_with("RAW_URL", "#{path} contains a URL") if value.match?(URL_VALUE)
      fail_with("EMAIL_ADDRESS", "#{path} contains an email address") if value.match?(EMAIL_VALUE)
      fail_with("PRECISE_COORDINATE", "#{path} contains a precise coordinate") if value.match?(COORDINATE_VALUE)
      fail_with("SECRET_LIKE_MATERIAL", "#{path} resembles secret material") if value.match?(SECRET_VALUE)
    end
  end
  def validate_telemetry(payload, operational)
    c = @policy.fetch("telemetry"); allowed = c.fetch("required_common_fields") + c.fetch("optional_common_fields") + (operational ? c.fetch("operational_fields") : c.fetch("product_fields"))
    exact_keys(payload, allowed); required(payload, c.fetch("required_common_fields")); require_environment(payload)
    enum(payload, "event_class", c.fetch("event_classes")); enum(payload, "result_class", c.fetch("result_classes")); enum(payload, "error_class", c.fetch("error_classes")) if payload.key?("error_class"); enum(payload, "route_id", c.fetch("route_ids")) if payload.key?("route_id"); enum(payload, "duration_bucket", c.fetch("duration_buckets")) if payload.key?("duration_bucket")
    if operational; required(payload, c.fetch("operational_fields")); enum(payload, "authorized_role_class", c.fetch("authorized_role_classes")); enum(payload, "latency_bucket", c.fetch("latency_buckets")); end
    payload.slice("correlation_id", "operation_id", "resource_id").each { |field, value| opaque_id(field, value) }; version_fields(payload, %w[telemetry_schema_version build_version api_contract_version schema_version])
    fail_with("INVALID_VALUE", "retry_count is outside the allowed range") if payload.key?("retry_count") && (!payload["retry_count"].is_a?(Integer) || payload["retry_count"] < 0 || payload["retry_count"] > c.fetch("max_retry_count"))
  end
  def validate_push(payload)
    c = @policy.fetch("push"); exact_keys(payload, c.fetch("required_fields")); required(payload, c.fetch("required_fields")); require_environment(payload); version_fields(payload, %w[push_schema_version build_version]); enum(payload, "notification_class", c.fetch("notification_classes")); enum(payload, "route_id", c.fetch("route_ids"))
    aps = payload.fetch("aps"); fail_with("INVALID_VALUE", "aps must be an object") unless aps.is_a?(Hash); exact_keys(aps, c.fetch("allowed_aps_fields"), "aps"); alert = aps.fetch("alert") { fail_with("MISSING_FIELD", "aps.alert is required") }; fail_with("INVALID_VALUE", "aps.alert must be an object") unless alert.is_a?(Hash); exact_keys(alert, c.fetch("allowed_alert_fields"), "aps.alert"); required(alert, ["loc-key"], "aps.alert"); enum(alert, "loc-key", c.fetch("localization_keys"), "aps.alert"); enum(aps, "category", c.fetch("categories"), "aps") if aps.key?("category"); enum(aps, "sound", c.fetch("sounds"), "aps") if aps.key?("sound"); opaque_id("aps.thread-id", aps["thread-id"]) if aps.key?("thread-id")
    fail_with("INVALID_VALUE", "aps.badge is outside the allowed range") if aps.key?("badge") && (!aps["badge"].is_a?(Integer) || aps["badge"] < 0 || aps["badge"] > c.fetch("max_badge")); fail_with("INVALID_VALUE", "aps.content-available must equal 1") if aps.key?("content-available") && aps["content-available"] != 1
  end
  def exact_keys(object, allowed, path = "payload"); object.each_key { |key| fail_with("UNKNOWN_FIELD", "#{path}.#{key} is not allowlisted") unless allowed.include?(key) }; end
  def required(object, fields, path = "payload"); fields.each { |field| fail_with("MISSING_FIELD", "#{path}.#{field} is required") unless object.key?(field) }; end
  def enum(object, field, values, path = "payload"); fail_with("INVALID_VALUE", "#{path}.#{field} is not an approved enum") unless values.include?(object.fetch(field)); end
  def opaque_id(field, value); fail_with("INVALID_OPAQUE_ID", "#{field} must be an opaque identifier") unless value.is_a?(String) && value.match?(@opaque_id); end
  def version_fields(payload, fields); fields.each { |field| fail_with("INVALID_VERSION", "#{field} must be a short version string") unless payload[field].is_a?(String) && payload[field].match?(/\A[0-9A-Za-z][0-9A-Za-z._-]{0,63}\z/) }; end
  def require_environment(payload)
    environment = payload.fetch("environment"); fail_with("INVALID_ENVIRONMENT", "environment is not approved") unless @policy.fetch("environments").include?(environment)
    payload.each_value { |value| next unless value.is_a?(String); foreign = @policy.fetch("environments") - [environment]; fail_with("MIXED_ENVIRONMENT", "payload contains a foreign environment marker") if foreign.any? { |name| value.downcase.include?(name) } }
  end
end

options = { policy: File.expand_path("../Config/SocialV2/privacy-payload-policy.json", __dir__), fixtures: File.expand_path("../Contracts/PrivacyFixtures", __dir__) }
OptionParser.new { |p| p.banner = "Usage: validate_social_privacy_payloads.rb [--policy PATH] [--fixtures PATH]"; p.on("--policy PATH") { |v| options[:policy] = v }; p.on("--fixtures PATH") { |v| options[:fixtures] = v } }.parse!
validator = PrivacyPayloadValidator.new(JSON.parse(File.read(options[:policy]))); fixtures = Dir.glob(File.join(options[:fixtures], "*.json")).sort; abort "No fixture files found in #{options[:fixtures]}" if fixtures.empty?; failures = []
fixtures.each do |path|
  fixture = JSON.parse(File.read(path)); expected = fixture["expect_error"]
  begin
    validator.validate(fixture.fetch("type"), fixture.fetch("payload")); expected ? failures << "FAIL #{File.basename(path)}: expected #{expected}, accepted" : puts("PASS #{File.basename(path)}: accepted")
  rescue PayloadError => error
    expected == error.code ? puts("PASS #{File.basename(path)}: rejected #{error.code}") : failures << "FAIL #{File.basename(path)}: expected #{expected || 'accept'}, got #{error.code} (#{error.message})"
  rescue JSON::ParserError => error
    failures << "FAIL #{File.basename(path)}: invalid JSON (#{error.message})"
  end
end
unless failures.empty? then warn failures.join("\n"); exit 1 end
puts "PASS: #{fixtures.length} deterministic privacy payload fixtures validated"
