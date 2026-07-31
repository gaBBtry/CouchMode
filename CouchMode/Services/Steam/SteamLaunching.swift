import Foundation

/// Boundary for detecting and opening Steam in a controller-friendly mode.
protocol SteamLaunching {
    var isInstalled: Bool { get async }
    func launchBigPicture() async throws
}
