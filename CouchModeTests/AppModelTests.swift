import XCTest
@testable import CouchMode

@MainActor
final class AppModelTests: XCTestCase {
    func testInitialStateComesFromPreferences() {
        let preferences = InMemoryAutomationPreferences(automationEnabled: false)
        let model = AppModel(
            preferences: preferences,
            displayWatcher: StubDisplayWatcher()
        )

        XCTAssertFalse(model.automationEnabled)
        XCTAssertEqual(model.statusText, "Automatisation désactivée")
    }

    func testChangingAutomationPersistsThePreference() {
        let preferences = InMemoryAutomationPreferences(automationEnabled: false)
        let model = AppModel(
            preferences: preferences,
            displayWatcher: StubDisplayWatcher()
        )

        model.setAutomationEnabled(true)

        XCTAssertTrue(model.automationEnabled)
        XCTAssertTrue(preferences.automationEnabled)
        XCTAssertEqual(model.statusText, "Automatisation active")
    }

    func testStartsDisplayMonitoringAtLaunch() {
        let displayWatcher = StubDisplayWatcher()

        _ = AppModel(
            preferences: InMemoryAutomationPreferences(automationEnabled: true),
            displayWatcher: displayWatcher
        )

        XCTAssertEqual(displayWatcher.connectedDisplaysCallCount, 1)
        XCTAssertEqual(displayWatcher.startCallCount, 1)
    }
}

private final class InMemoryAutomationPreferences: AutomationPreferencesStoring {
    var automationEnabled: Bool

    init(automationEnabled: Bool) {
        self.automationEnabled = automationEnabled
    }
}

private final class StubDisplayWatcher: DisplayWatching {
    private(set) var connectedDisplaysCallCount = 0
    private(set) var startCallCount = 0

    func connectedDisplays() throws -> [DisplaySummary] {
        connectedDisplaysCallCount += 1
        return []
    }

    func start(eventHandler: @escaping EventHandler) throws {
        startCallCount += 1
    }

    func stop() {}
}
