import Foundation

struct DisplayIdentifier: Hashable, Codable, Sendable {
    let rawValue: String
}

struct DisplaySummary: Equatable, Sendable {
    let identifier: DisplayIdentifier
    let name: String
    let isBuiltIn: Bool
}

struct AudioOutputSummary: Equatable, Sendable {
    let identifier: String
    let name: String
}
