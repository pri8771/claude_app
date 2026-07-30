import XCTest
@testable import Hindsight

final class SocialV2RolloutPolicyTests: XCTestCase {
    private let accountID = SocialV2AccountID("account-opaque-1")!

    private func context(
        environment: SocialV2Environment = .qa,
        accountID: SocialV2AccountID? = SocialV2AccountID("account-opaque-1"),
        contractVersion: Int = 2,
        appBuild: Int = 200
    ) -> SocialV2ClientContext {
        SocialV2ClientContext(
            environment: environment,
            accountID: accountID,
            contractVersion: contractVersion,
            appBuild: appBuild
        )
    }

    private func policy(_ flags: Set<SocialV2Flag> = []) -> SocialV2RolloutPolicy {
        SocialV2RolloutPolicy(configuration: .allDisabled(
            environment: .qa,
            accountID: accountID,
            minimumContractVersion: 2,
            minimumAppBuild: 200
        ).replacing(enabledFlags: flags))
    }

    func testAllDisabledDefaultsNeverEnableAnyFlag() {
        let policy = policy()
        for flag in SocialV2Flag.allCases {
            XCTAssertEqual(policy.decision(for: flag, context: context()), .disabled(.disabledByConfiguration))
        }
    }

    func testAccountIDRequiresAnOpaqueBoundedIdentifier() {
        XCTAssertNotNil(SocialV2AccountID("account-opaque-1"))
        XCTAssertNil(SocialV2AccountID(""))
        XCTAssertNil(SocialV2AccountID("short"))
        XCTAssertNil(SocialV2AccountID("person@example.com"))
        XCTAssertNil(SocialV2AccountID(String(repeating: "a", count: 65)))
    }

    func testValidStagedCombinationsEnableOnlyTheirConfiguredFlags() {
        XCTAssertTrue(policy([.socialRead]).decision(for: .socialRead, context: context()).isEnabled)
        XCTAssertTrue(policy([.socialRead, .socialWrite]).decision(for: .socialWrite, context: context()).isEnabled)
        XCTAssertTrue(policy([.socialRead, .privateSyncOptIn]).decision(for: .privateSyncOptIn, context: context()).isEnabled)
        XCTAssertTrue(policy([.socialRead, .backgroundSync]).decision(for: .backgroundSync, context: context()).isEnabled)
        XCTAssertTrue(policy([.socialRead, .socialWrite, .privateSyncOptIn, .migrationStart]).decision(for: .migrationStart, context: context()).isEnabled)
    }

    func testInvalidDependenciesFailClosedForEveryFlag() {
        let invalidConfigurations: [Set<SocialV2Flag>] = [
            [.socialWrite],
            [.privateSyncOptIn],
            [.backgroundSync],
            [.socialRead, .socialWrite, .migrationStart],
            [.socialRead, .privateSyncOptIn, .migrationStart]
        ]

        for flags in invalidConfigurations {
            for flag in SocialV2Flag.allCases {
                XCTAssertFalse(policy(flags).decision(for: flag, context: context()).isEnabled, "\(flags) unexpectedly enabled \(flag)")
            }
        }
        XCTAssertEqual(policy([.socialWrite]).decision(for: .socialWrite, context: context()).reasonCode, .socialReadRequired)
        XCTAssertEqual(policy([.socialRead, .socialWrite, .migrationStart]).decision(for: .migrationStart, context: context()).reasonCode, .privateSyncOptInRequired)
    }

    func testEnvironmentAndAccountMismatchFailClosed() {
        let rollout = policy([.socialRead])
        XCTAssertEqual(rollout.decision(for: .socialRead, context: context(environment: .production)).reasonCode, .environmentMismatch)
        XCTAssertEqual(rollout.decision(for: .socialRead, context: context(accountID: SocialV2AccountID("different-account"))).reasonCode, .accountMismatch)
        XCTAssertEqual(rollout.decision(for: .socialRead, context: context(accountID: nil)).reasonCode, .accountMismatch)
    }

    func testStaleContractOrBuildFailsClosed() {
        let rollout = policy([.socialRead])
        XCTAssertEqual(rollout.decision(for: .socialRead, context: context(contractVersion: 1)).reasonCode, .unsupportedContractVersion)
        XCTAssertEqual(rollout.decision(for: .socialRead, context: context(appBuild: 199)).reasonCode, .unsupportedAppBuild)
    }

    func testInvalidMinimumsFailClosed() {
        let invalidContract = SocialV2RolloutPolicy(configuration: SocialV2RolloutConfiguration(environment: .qa, accountID: accountID, minimumContractVersion: 0, minimumAppBuild: 200, enabledFlags: [.socialRead]))
        let invalidBuild = SocialV2RolloutPolicy(configuration: SocialV2RolloutConfiguration(environment: .qa, accountID: accountID, minimumContractVersion: 2, minimumAppBuild: 0, enabledFlags: [.socialRead]))
        XCTAssertEqual(invalidContract.decision(for: .socialRead, context: context()).reasonCode, .invalidMinimumContractVersion)
        XCTAssertEqual(invalidBuild.decision(for: .socialRead, context: context()).reasonCode, .invalidMinimumAppBuild)
    }
}

private extension SocialV2RolloutConfiguration {
    func replacing(enabledFlags: Set<SocialV2Flag>) -> Self {
        Self(
            environment: environment,
            accountID: accountID,
            minimumContractVersion: minimumContractVersion,
            minimumAppBuild: minimumAppBuild,
            enabledFlags: enabledFlags
        )
    }
}
