import Foundation
import OSLog

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var automationEnabled: Bool

    private let preferences: AutomationPreferencesStoring
    private let displayWatcher: DisplayWatching
    private let logger: Logger

    init(
        preferences: AutomationPreferencesStoring,
        displayWatcher: DisplayWatching = DisplayWatcher(),
        logger: Logger = Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "CouchMode",
            category: "Application"
        )
    ) {
        self.preferences = preferences
        self.displayWatcher = displayWatcher
        self.logger = logger
        automationEnabled = preferences.automationEnabled

        let automationStatus = automationEnabled ? "enabled" : "disabled"
        logger.info("CouchMode started; automation is \(automationStatus, privacy: .public)")
        startDisplayMonitoring()
    }

    var statusText: String {
        automationEnabled ? "Automatisation active" : "Automatisation désactivée"
    }

    func setAutomationEnabled(_ enabled: Bool) {
        guard automationEnabled != enabled else { return }

        automationEnabled = enabled
        preferences.automationEnabled = enabled
        let automationStatus = enabled ? "enabled" : "disabled"
        logger.info("Automation changed to \(automationStatus, privacy: .public)")
    }

    private func startDisplayMonitoring() {
        do {
            let displays = try displayWatcher.connectedDisplays()
            logger.info("Display monitoring found \(displays.count, privacy: .public) online display(s)")

            for display in displays {
                logDisplay(display, state: "available")
            }

            try displayWatcher.start { [logger] event in
                let state = switch event.state {
                case .connected: "connected"
                case .disconnected: "disconnected"
                }

                logger.info("Display \(state, privacy: .public): name=\(event.display.name, privacy: .public), id=\(event.display.identifier.rawValue, privacy: .public), builtIn=\(event.display.isBuiltIn, privacy: .public)")
            }

            logger.info("Display monitoring started")
        } catch {
            logger.error("Display monitoring failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func logDisplay(_ display: DisplaySummary, state: String) {
        logger.info("Display \(state, privacy: .public): name=\(display.name, privacy: .public), id=\(display.identifier.rawValue, privacy: .public), builtIn=\(display.isBuiltIn, privacy: .public)")
    }
}
