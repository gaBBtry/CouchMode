import Foundation

struct DisplayIdentifier: Hashable, Codable, Sendable {
    let rawValue: String
}

struct DisplaySummary: Equatable, Sendable {
    let identifier: DisplayIdentifier
    let name: String
    let isBuiltIn: Bool
}

enum DisplayConnectionState: Equatable, Sendable {
    case connected
    case disconnected
}

struct DisplayConnectionEvent: Equatable, Sendable {
    let state: DisplayConnectionState
    let display: DisplaySummary
}

struct AudioOutputSummary: Equatable, Sendable {
    let identifier: String
    let name: String
}
