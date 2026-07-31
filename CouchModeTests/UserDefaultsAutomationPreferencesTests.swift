import XCTest
@testable import CouchMode

final class UserDefaultsAutomationPreferencesTests: XCTestCase {
    private var defaults: UserDefaults?
    private var suiteName: String?

    override func setUpWithError() throws {
        try super.setUpWithError()

        let suiteName = "CouchModeTests.\(UUID().uuidString)"
        self.suiteName = suiteName
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
    }

    override func tearDownWithError() throws {
        if let suiteName {
            defaults?.removePersistentDomain(forName: suiteName)
        }

        defaults = nil
        suiteName = nil
        try super.tearDownWithError()
    }

    func testAutomationDefaultsToEnabled() throws {
        let defaults = try XCTUnwrap(defaults)
        let preferences = UserDefaultsAutomationPreferences(defaults: defaults)

        XCTAssertTrue(preferences.automationEnabled)
    }

    func testAutomationValueSurvivesStoreRecreation() throws {
        let defaults = try XCTUnwrap(defaults)
        UserDefaultsAutomationPreferences(defaults: defaults).automationEnabled = false

        let reloadedPreferences = UserDefaultsAutomationPreferences(defaults: defaults)

        XCTAssertFalse(reloadedPreferences.automationEnabled)
    }
}
