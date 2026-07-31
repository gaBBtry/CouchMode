import Foundation

/// Boundary for display discovery and configuration.
///
/// A BetterDisplay-backed implementation can be added without exposing its CLI
/// details to the rest of the application.
protocol DisplayConfiguring {
    func connectedDisplays() async throws -> [DisplaySummary]
    func activateGameConfiguration(for display: DisplayIdentifier) async throws
    func restorePreviousConfiguration() async throws
}
