import Foundation

/// Boundary for selecting and restoring the system audio output.
protocol AudioManaging {
    func availableOutputs() async throws -> [AudioOutputSummary]
    func routeAudio(to outputIdentifier: String) async throws
    func restorePreviousOutput() async throws
}
