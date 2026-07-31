import XCTest
@testable import CouchMode

final class UserDefaultsAutomationPreferencesTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "CouchModeTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testAutomationDefaultsToEnabled() {
        let preferences = UserDefaultsAutomationPreferences(defaults: defaults)

        XCTAssertTrue(preferences.automationEnabled)
    }

    func testAutomationValueSurvivesStoreRecreation() {
        UserDefaultsAutomationPreferences(defaults: defaults).automationEnabled = false

        let reloadedPreferences = UserDefaultsAutomationPreferences(defaults: defaults)

        XCTAssertFalse(reloadedPreferences.automationEnabled)
    }
}
