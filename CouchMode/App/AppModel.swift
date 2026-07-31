import Foundation
import OSLog

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var automationEnabled: Bool

    private let preferences: AutomationPreferencesStoring
    private let logger: Logger

    init(
        preferences: AutomationPreferencesStoring,
        logger: Logger = Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "CouchMode",
            category: "Application"
        )
    ) {
        self.preferences = preferences
        self.logger = logger
        automationEnabled = preferences.automationEnabled

        logger.info("CouchMode started; automation is \(self.automationEnabled ? "enabled" : "disabled")")
    }

    var statusText: String {
        automationEnabled ? "Automatisation active" : "Automatisation désactivée"
    }

    func setAutomationEnabled(_ enabled: Bool) {
        guard automationEnabled != enabled else { return }

        automationEnabled = enabled
        preferences.automationEnabled = enabled
        logger.info("Automation changed to \(enabled ? "enabled" : "disabled")")
    }
}
