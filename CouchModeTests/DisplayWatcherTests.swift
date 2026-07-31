import CoreGraphics
import Foundation
import XCTest
@testable import CouchMode

final class DisplayWatcherTests: XCTestCase {
    func testConnectedDisplaysExposeBuiltInAndExternalDisplays() throws {
        let builtIn = display(id: "built-in", name: "Écran du MacBook", isBuiltIn: true)
        let external = display(id: "living-room-tv", name: "TV du salon", isBuiltIn: false)
        let provider = StubDisplayProvider(
            displayIDs: [1, 2],
            summaries: [1: builtIn, 2: external]
        )
        let watcher = DisplayWatcher(provider: provider, observer: StubDisplayObserver())

        let displays = try watcher.connectedDisplays()

        XCTAssertEqual(displays, [builtIn, external])
    }

    func testAddingExternalDisplayProducesConnectedEvent() throws {
        let external = display(id: "living-room-tv", name: "TV du salon", isBuiltIn: false)
        let provider = StubDisplayProvider()
        let observer = StubDisplayObserver()
        let watcher = DisplayWatcher(provider: provider, observer: observer)
        let events = EventRecorder()
        try watcher.start { @Sendable event in events.record(event) }

        provider.summaries[42] = external
        observer.emit(displayID: 42, flags: .addFlag)

        XCTAssertEqual(events.values, [.init(state: .connected, display: external)])
    }

    func testRemovingDisplayUsesCachedMetadata() throws {
        let external = display(id: "living-room-tv", name: "TV du salon", isBuiltIn: false)
        let provider = StubDisplayProvider(
            displayIDs: [42],
            summaries: [42: external]
        )
        let observer = StubDisplayObserver()
        let watcher = DisplayWatcher(provider: provider, observer: observer)
        let events = EventRecorder()
        try watcher.start { @Sendable event in events.record(event) }

        provider.displayIDs = []
        provider.summaries[42] = nil
        observer.emit(displayID: 42, flags: .removeFlag)

        XCTAssertEqual(events.values, [.init(state: .disconnected, display: external)])
    }

    func testRepeatedRemovalCallbacksRemainVisibleToTheOrchestrator() throws {
        let external = display(id: "living-room-tv", name: "TV du salon", isBuiltIn: false)
        let provider = StubDisplayProvider(
            displayIDs: [42],
            summaries: [42: external]
        )
        let observer = StubDisplayObserver()
        let watcher = DisplayWatcher(provider: provider, observer: observer)
        let events = EventRecorder()
        try watcher.start { @Sendable event in events.record(event) }

        observer.emit(displayID: 42, flags: .removeFlag)
        observer.emit(displayID: 42, flags: .removeFlag)

        XCTAssertEqual(events.values, [
            .init(state: .disconnected, display: external),
            .init(state: .disconnected, display: external),
        ])
    }

    func testBeginningOfConfigurationDoesNotProduceEvent() throws {
        let provider = StubDisplayProvider()
        let observer = StubDisplayObserver()
        let watcher = DisplayWatcher(provider: provider, observer: observer)
        let events = EventRecorder()
        try watcher.start { @Sendable event in events.record(event) }

        observer.emit(displayID: 42, flags: .beginConfigurationFlag)

        XCTAssertTrue(events.values.isEmpty)
    }

    func testStartingTwiceFailsClearly() throws {
        let watcher = DisplayWatcher(
            provider: StubDisplayProvider(),
            observer: StubDisplayObserver()
        )
        try watcher.start { _ in }

        XCTAssertThrowsError(try watcher.start { _ in }) { error in
            XCTAssertEqual(error as? DisplayWatcherError, .alreadyStarted)
        }
    }

    func testStopUnregistersObserver() throws {
        let observer = StubDisplayObserver()
        let watcher = DisplayWatcher(provider: StubDisplayProvider(), observer: observer)
        try watcher.start { _ in }

        watcher.stop()

        XCTAssertEqual(observer.unregisterCallCount, 1)
    }

    private func display(id: String, name: String, isBuiltIn: Bool) -> DisplaySummary {
        DisplaySummary(
            identifier: DisplayIdentifier(rawValue: id),
            name: name,
            isBuiltIn: isBuiltIn
        )
    }
}

private final class StubDisplayProvider: DisplayProviding {
    var displayIDs: [CGDirectDisplayID]
    var summaries: [CGDirectDisplayID: DisplaySummary]

    init(
        displayIDs: [CGDirectDisplayID] = [],
        summaries: [CGDirectDisplayID: DisplaySummary] = [:]
    ) {
        self.displayIDs = displayIDs
        self.summaries = summaries
    }

    func onlineDisplayIDs() throws -> [CGDirectDisplayID] {
        displayIDs
    }

    func summary(for displayID: CGDirectDisplayID) -> DisplaySummary? {
        summaries[displayID]
    }
}

private final class EventRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var events: [DisplayConnectionEvent] = []

    var values: [DisplayConnectionEvent] {
        lock.lock()
        defer { lock.unlock() }
        return events
    }

    func record(_ event: DisplayConnectionEvent) {
        lock.lock()
        events.append(event)
        lock.unlock()
    }
}

private final class StubDisplayObserver: DisplayReconfigurationObserving {
    private var handler: (@Sendable (CGDirectDisplayID, CGDisplayChangeSummaryFlags) -> Void)?
    private(set) var unregisterCallCount = 0

    func register(
        handler: @escaping @Sendable (CGDirectDisplayID, CGDisplayChangeSummaryFlags) -> Void
    ) throws {
        self.handler = handler
    }

    func unregister() {
        unregisterCallCount += 1
        handler = nil
    }

    func emit(displayID: CGDirectDisplayID, flags: CGDisplayChangeSummaryFlags) {
        handler?(displayID, flags)
    }
}
