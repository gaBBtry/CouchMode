import XCTest
@testable import CouchMode

@MainActor
final class AppModelTests: XCTestCase {
    func testInitialStateComesFromPreferences() {
        let preferences = InMemoryAutomationPreferences(automationEnabled: false)
        let model = AppModel(preferences: preferences)

        XCTAssertFalse(model.automationEnabled)
        XCTAssertEqual(model.statusText, "Automatisation désactivée")
    }

    func testChangingAutomationPersistsThePreference() {
        let preferences = InMemoryAutomationPreferences(automationEnabled: false)
        let model = AppModel(preferences: preferences)

        model.setAutomationEnabled(true)

        XCTAssertTrue(model.automationEnabled)
        XCTAssertTrue(preferences.automationEnabled)
        XCTAssertEqual(model.statusText, "Automatisation active")
    }
}

private final class InMemoryAutomationPreferences: AutomationPreferencesStoring {
    var automationEnabled: Bool

    init(automationEnabled: Bool) {
        self.automationEnabled = automationEnabled
    }
}
