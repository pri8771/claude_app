//
//  SocialV2RolloutPolicy.swift
//  Hindsight
//
//  A local, pure policy boundary for Social v2 rollout decisions. Configuration
//  must be supplied by a trusted, release-controlled integration point; this
//  type deliberately does not read UserDefaults, process arguments, or disk.
//

import Foundation

enum SocialV2Environment: String, CaseIterable, Sendable {
    case development
    case qa
    case production
}

enum SocialV2Flag: String, CaseIterable, Sendable {
    case socialRead = "social_read"
    case socialWrite = "social_write"
    case privateSyncOptIn = "private_sync_opt_in"
    case migrationStart = "migration_start"
    case backgroundSync = "background_sync"
}

/// An opaque account binding. It is deliberately never included in a decision
/// reason, so callers can safely record only the reason code in diagnostics.
struct SocialV2AccountID: Hashable, Sendable {
    let rawValue: String

    init?(_ rawValue: String) {
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_-"))
        guard (12...64).contains(rawValue.count),
              rawValue.unicodeScalars.allSatisfy(allowedCharacters.contains) else {
            return nil
        }
        self.rawValue = rawValue
    }
}

struct SocialV2ClientContext: Equatable, Sendable {
    let environment: SocialV2Environment
    let accountID: SocialV2AccountID?
    /// Integer compatibility epoch for the `social.v1` client contract, not the display semver.
    let contractVersion: Int
    let appBuild: Int

    init(
        environment: SocialV2Environment,
        accountID: SocialV2AccountID?,
        contractVersion: Int,
        appBuild: Int
    ) {
        self.environment = environment
        self.accountID = accountID
        self.contractVersion = contractVersion
        self.appBuild = appBuild
    }
}

struct SocialV2RolloutConfiguration: Equatable, Sendable {
    let environment: SocialV2Environment
    let accountID: SocialV2AccountID
    let minimumContractVersion: Int
    let minimumAppBuild: Int
    let enabledFlags: Set<SocialV2Flag>

    init(
        environment: SocialV2Environment,
        accountID: SocialV2AccountID,
        minimumContractVersion: Int,
        minimumAppBuild: Int,
        enabledFlags: Set<SocialV2Flag> = []
    ) {
        self.environment = environment
        self.accountID = accountID
        self.minimumContractVersion = minimumContractVersion
        self.minimumAppBuild = minimumAppBuild
        self.enabledFlags = enabledFlags
    }

    /// The only built-in configuration is an immutable, all-off state.
    static func allDisabled(
        environment: SocialV2Environment,
        accountID: SocialV2AccountID,
        minimumContractVersion: Int,
        minimumAppBuild: Int
    ) -> Self {
        Self(
            environment: environment,
            accountID: accountID,
            minimumContractVersion: minimumContractVersion,
            minimumAppBuild: minimumAppBuild
        )
    }
}

enum SocialV2RolloutReasonCode: String, Equatable, Sendable {
    case enabled
    case disabledByConfiguration = "disabled_by_configuration"
    case invalidMinimumContractVersion = "invalid_minimum_contract_version"
    case invalidMinimumAppBuild = "invalid_minimum_app_build"
    case socialReadRequired = "social_read_required"
    case socialWriteRequired = "social_write_required"
    case privateSyncOptInRequired = "private_sync_opt_in_required"
    case environmentMismatch = "environment_mismatch"
    case accountMismatch = "account_mismatch"
    case unsupportedContractVersion = "unsupported_contract_version"
    case unsupportedAppBuild = "unsupported_app_build"
}

struct SocialV2RolloutDecision: Equatable, Sendable {
    let isEnabled: Bool
    let reasonCode: SocialV2RolloutReasonCode

    static let enabled = Self(isEnabled: true, reasonCode: .enabled)

    static func disabled(_ reasonCode: SocialV2RolloutReasonCode) -> Self {
        Self(isEnabled: false, reasonCode: reasonCode)
    }
}

/// Fail-closed evaluator for a release-provided Social v2 configuration.
///
/// This type has no persistence or configuration-loading API. In particular,
/// it cannot enable a flag from UserDefaults or process arguments.
struct SocialV2RolloutPolicy: Sendable {
    let configuration: SocialV2RolloutConfiguration

    init(configuration: SocialV2RolloutConfiguration) {
        self.configuration = configuration
    }

    func decision(for flag: SocialV2Flag, context: SocialV2ClientContext) -> SocialV2RolloutDecision {
        if let configurationFailure = configurationFailureReason {
            return .disabled(configurationFailure)
        }
        guard context.environment == configuration.environment else {
            return .disabled(.environmentMismatch)
        }
        guard context.accountID == configuration.accountID else {
            return .disabled(.accountMismatch)
        }
        guard context.contractVersion >= configuration.minimumContractVersion else {
            return .disabled(.unsupportedContractVersion)
        }
        guard context.appBuild >= configuration.minimumAppBuild else {
            return .disabled(.unsupportedAppBuild)
        }
        guard configuration.enabledFlags.contains(flag) else {
            return .disabled(.disabledByConfiguration)
        }
        if let dependencyFailure = dependencyFailureReason(for: flag) {
            return .disabled(dependencyFailure)
        }
        return .enabled
    }

    private var configurationFailureReason: SocialV2RolloutReasonCode? {
        guard configuration.minimumContractVersion > 0 else {
            return .invalidMinimumContractVersion
        }
        guard configuration.minimumAppBuild > 0 else {
            return .invalidMinimumAppBuild
        }
        return dependencyFailureReason(for: nil)
    }

    private func dependencyFailureReason(for flag: SocialV2Flag?) -> SocialV2RolloutReasonCode? {
        let flags = configuration.enabledFlags
        let requiresRead = flag == nil || flag == .socialWrite || flag == .privateSyncOptIn || flag == .migrationStart || flag == .backgroundSync
        if requiresRead,
           (flags.contains(.socialWrite) || flags.contains(.privateSyncOptIn) || flags.contains(.migrationStart) || flags.contains(.backgroundSync)),
           !flags.contains(.socialRead) {
            return .socialReadRequired
        }
        if (flag == nil || flag == .migrationStart), flags.contains(.migrationStart), !flags.contains(.socialWrite) {
            return .socialWriteRequired
        }
        if (flag == nil || flag == .migrationStart), flags.contains(.migrationStart), !flags.contains(.privateSyncOptIn) {
            return .privateSyncOptInRequired
        }
        return nil
    }
}
