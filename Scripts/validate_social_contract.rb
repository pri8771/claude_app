#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"

ROOT = File.expand_path("..", __dir__)
CONTRACT = File.join(ROOT, "Contracts/social-v1.openapi.yaml")
FIXTURES = File.join(ROOT, "Contracts/Fixtures/social-v2-negative-cases.json")
POSITIVES = File.join(ROOT, "Contracts/Fixtures/social-v2-positive-cases.json")
HTTP_METHODS = %w[get put post patch delete head options trace].freeze
MUTATING_METHODS = %w[put post patch delete].freeze
NEGATIVE_REASONS = {
  1 => %w[NOT_FOUND FORBIDDEN], 2 => %w[MEMBERSHIP_INACTIVE],
  3 => %w[FORECAST_EXISTS locked], 4 => %w[FORECAST_DEADLINE_PASSED],
  5 => %w[IDEMPOTENCY_KEY_REUSED], 6 => %w[CONFLICT_VERSION],
  7 => %w[EVENT_NOT_OPEN VALIDATION_FAILED], 8 => %w[FORBIDDEN redacted],
  9 => %w[INVITE_INVALID], 10 => %w[POLICY_NOT_CONFIGURED],
  11 => %w[VALIDATION_FAILED POLICY_NOT_CONFIGURED], 12 => %w[append_only_reject],
  13 => %w[NOT_FOUND], 14 => %w[converges_by_version_cursor],
  15 => %w[NOT_FOUND cursor_valid], 16 => %w[UNAUTHENTICATED NOT_FOUND]
}.freeze
LEAK = /(?:bearer\s+\S+|api[_-]?key|password|credential|secret|private[_-]?key|sk_[a-z0-9]+)/i
CONTENT_KEYS = /(?:prompt|prediction|outcome|note|group_?name|display_?name|invite_?token)/i

def fail!(message)
  warn "FAIL: #{message}"
  exit 1
end

def deref(root, value)
  return value unless value.is_a?(Hash) && value["$ref"]
  ref = value["$ref"]
  fail!("external reference is not permitted: #{ref}") unless ref.start_with?("#/")
  ref.delete_prefix("#/").split("/").map { |key| key.gsub("~1", "/").gsub("~0", "~") }
     .reduce(root) { |node, key| node.is_a?(Hash) ? node[key] : nil } ||
    fail!("unresolved reference: #{ref}")
end

def walk(value, &block)
  yield value
  case value
  when Hash then value.each_value { |item| walk(item, &block) }
  when Array then value.each { |item| walk(item, &block) }
  end
end

def operation_parameters(root, path_item, operation)
  (Array(path_item["parameters"]) + Array(operation["parameters"])).map { |item| deref(root, item) }
end

def contains_content_key?(value)
  case value
  when Hash
    value.any? { |key, child| key.match?(CONTENT_KEYS) || contains_content_key?(child) }
  when Array
    value.any? { |child| contains_content_key?(child) }
  else
    false
  end
end

def json_schemas(root, response)
  resolved = deref(root, response)
  content = resolved["content"] || {}
  content.each_with_object([]) do |(mime, media), schemas|
    schemas << media["schema"] if mime.include?("json")
  end
end

def validate_contract(contract)
  fail!("OpenAPI version must be 3.1.x") unless contract["openapi"].to_s.start_with?("3.1.")
  fail!("missing info.version") if contract.dig("info", "version").to_s.empty?
  fail!("missing paths") unless contract["paths"].is_a?(Hash) && !contract["paths"].empty?
  fail!("global bearer security is required") unless contract["security"] == [{ "bearerAuth" => [] }]
  fail!("bearerAuth scheme is missing") unless contract.dig("components", "securitySchemes", "bearerAuth", "type") == "http"

  refs = []
  walk(contract) { |node| refs << node["$ref"] if node.is_a?(Hash) && node["$ref"] }
  refs.each { |ref| deref(contract, { "$ref" => ref }) }

  operation_ids = []
  contract.fetch("paths").each do |path, path_item|
    fail!("path #{path} is not an object") unless path_item.is_a?(Hash)
    path_item.each do |method, operation|
      next unless HTTP_METHODS.include?(method)
      fail!("#{method.upcase} #{path} has no operationId") if operation["operationId"].to_s.empty?
      operation_ids << operation["operationId"]
      fail!("#{method.upcase} #{path} lacks explicit/global security") unless operation.key?("security") || contract["security"]
      if MUTATING_METHODS.include?(method)
        idempotency = operation_parameters(contract, path_item, operation).any? { |param| param["name"] == "Idempotency-Key" && param["in"] == "header" && param["required"] }
        fail!("#{method.upcase} #{path} lacks required Idempotency-Key") unless idempotency
      end
      operation.fetch("responses", {}).each do |status, response|
        schemas = json_schemas(contract, response)
        next if schemas.empty?
        schemas.each do |schema|
          target = deref(contract, schema)
          fail!("#{method.upcase} #{path} #{status} JSON response lacks a stable schema reference") unless schema.is_a?(Hash) && schema["$ref"] && target
        end
      end
    end
  end
  duplicates = operation_ids.group_by(&:itself).select { |_id, values| values.length > 1 }.keys
  fail!("duplicate operationIds: #{duplicates.join(", ")}") unless duplicates.empty?

  contract.fetch("components").fetch("responses").each do |name, response|
    next unless name =~ /Unauthenticated|Forbidden|NotFound|Invalid|Validation|Conflict|Policy|Rate/
    schemas = json_schemas(contract, response)
    fail!("error response #{name} has no JSON Error schema") unless schemas.any? { |schema| schema["$ref"] == "#/components/schemas/Error" }
  end
  walk(contract) do |node|
    next unless node.is_a?(Hash) && (node.key?("example") || node.key?("examples"))
    JSON.generate(node).tap { |text| fail!("example contains secret-like material") if text.match?(LEAK) }
  end
end

def validate_fixture_file(path, negative:)
  document = JSON.parse(File.read(path))
  fail!("#{path} must be an object with cases") unless document["cases"].is_a?(Array) && !document["cases"].empty?
  document["cases"].each do |fixture|
    id = fixture["case_id"]
    fail!("#{path}: fixture has no case_id") if id.to_s.empty?
    serialized = JSON.generate(fixture)
    fail!("#{path}: #{id} contains secret-like material") if serialized.match?(LEAK)
    fail!("#{path}: #{id} contains prohibited content field") if contains_content_key?(fixture.fetch("request", {}))
    expected = fixture["expected"] || {}
    if negative
      number = id.to_s[/\d+/].to_i
      allowed = NEGATIVE_REASONS[number] || fail!("#{path}: unknown negative case #{id}")
      fail!("#{path}: #{id} must be rejected") unless expected["outcome"] == "rejected"
      fail!("#{path}: #{id} has an unintended reason") unless allowed.include?(expected["reason"])
    else
      fail!("#{path}: #{id} must be accepted") unless expected["outcome"] == "accepted"
    end
  end
  document
end

begin
  validate_contract(YAML.safe_load(File.read(CONTRACT), aliases: true))
  positives = validate_fixture_file(POSITIVES, negative: false)
  negatives = validate_fixture_file(FIXTURES, negative: true)
  puts "PASS: OpenAPI structure, references, security, idempotency, schemas, and examples"
  puts "PASS: #{positives["cases"].length} positive fixture expectations validated"
  puts "PASS: #{negatives["cases"].length} negative fixture expectations validated"
rescue Psych::Exception, JSON::ParserError => error
  fail!("parse error: #{error.message}")
end
