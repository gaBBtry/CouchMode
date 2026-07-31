import AppKit
import ColorSync
import CoreGraphics
import Foundation

protocol DisplayWatching: AnyObject {
    typealias EventHandler = @Sendable (DisplayConnectionEvent) -> Void

    func connectedDisplays() throws -> [DisplaySummary]
    func start(eventHandler: @escaping EventHandler) throws
    func stop()
}

enum DisplayWatcherError: Error, Equatable, LocalizedError {
    case alreadyStarted
    case displayEnumerationFailed(code: Int32)
    case callbackRegistrationFailed(code: Int32)

    var errorDescription: String? {
        switch self {
        case .alreadyStarted:
            return "La surveillance des écrans est déjà active."
        case let .displayEnumerationFailed(code):
            return "Impossible d’énumérer les écrans connectés (erreur CoreGraphics \(code))."
        case let .callbackRegistrationFailed(code):
            return "Impossible de surveiller les changements d’écran (erreur CoreGraphics \(code))."
        }
    }
}

protocol DisplayProviding: AnyObject {
    func onlineDisplayIDs() throws -> [CGDirectDisplayID]
    func summary(for displayID: CGDirectDisplayID) -> DisplaySummary?
}

protocol DisplayReconfigurationObserving: AnyObject {
    func register(
        handler: @escaping @Sendable (CGDirectDisplayID, CGDisplayChangeSummaryFlags) -> Void
    ) throws
    func unregister()
}

final class DisplayWatcher: DisplayWatching {
    private let provider: DisplayProviding
    private let observer: DisplayReconfigurationObserving
    private let lock = NSLock()

    private var cachedDisplays: [CGDirectDisplayID: DisplaySummary] = [:]
    private var eventHandler: EventHandler?

    init(
        provider: DisplayProviding = CoreGraphicsDisplayProvider(),
        observer: DisplayReconfigurationObserving = CoreGraphicsDisplayReconfigurationObserver()
    ) {
        self.provider = provider
        self.observer = observer
    }

    deinit {
        observer.unregister()
    }

    func connectedDisplays() throws -> [DisplaySummary] {
        try currentDisplaySnapshot().map(\.value)
    }

    func start(eventHandler: @escaping EventHandler) throws {
        let snapshot = try currentDisplaySnapshot()

        lock.lock()
        guard self.eventHandler == nil else {
            lock.unlock()
            throw DisplayWatcherError.alreadyStarted
        }
        cachedDisplays = Dictionary(uniqueKeysWithValues: snapshot.map { ($0.id, $0.value) })
        self.eventHandler = eventHandler
        lock.unlock()

        do {
            try observer.register { [weak self] displayID, flags in
                self?.handleReconfiguration(for: displayID, flags: flags)
            }
        } catch {
            lock.lock()
            cachedDisplays.removeAll()
            self.eventHandler = nil
            lock.unlock()
            throw error
        }
    }

    func stop() {
        lock.lock()
        cachedDisplays.removeAll()
        eventHandler = nil
        lock.unlock()

        observer.unregister()
    }

    private func currentDisplaySnapshot() throws -> [(id: CGDirectDisplayID, value: DisplaySummary)] {
        try provider.onlineDisplayIDs().compactMap { displayID in
            provider.summary(for: displayID).map { (displayID, $0) }
        }
    }

    private func handleReconfiguration(
        for displayID: CGDirectDisplayID,
        flags: CGDisplayChangeSummaryFlags
    ) {
        guard !flags.contains(.beginConfigurationFlag) else { return }

        if flags.contains(.addFlag), let display = provider.summary(for: displayID) {
            emit(.init(state: .connected, display: display), caching: display, for: displayID)
        }

        if flags.contains(.removeFlag) {
            emitRemoval(for: displayID)
        }
    }

    private func emit(
        _ event: DisplayConnectionEvent,
        caching display: DisplaySummary,
        for displayID: CGDirectDisplayID
    ) {
        lock.lock()
        cachedDisplays[displayID] = display
        let handler = eventHandler
        lock.unlock()

        handler?(event)
    }

    private func emitRemoval(for displayID: CGDirectDisplayID) {
        lock.lock()
        let display = cachedDisplays[displayID]
        let handler = eventHandler
        lock.unlock()

        guard let display else { return }
        handler?(.init(state: .disconnected, display: display))
    }
}

final class CoreGraphicsDisplayProvider: DisplayProviding {
    func onlineDisplayIDs() throws -> [CGDirectDisplayID] {
        var displayCount: UInt32 = 0
        let countResult = CGGetOnlineDisplayList(0, nil, &displayCount)
        guard countResult == .success else {
            throw DisplayWatcherError.displayEnumerationFailed(code: countResult.rawValue)
        }
        guard displayCount > 0 else { return [] }

        var displayIDs = [CGDirectDisplayID](repeating: 0, count: Int(displayCount))
        let listResult = CGGetOnlineDisplayList(displayCount, &displayIDs, &displayCount)
        guard listResult == .success else {
            throw DisplayWatcherError.displayEnumerationFailed(code: listResult.rawValue)
        }

        return Array(displayIDs.prefix(Int(displayCount)))
    }

    func summary(for displayID: CGDirectDisplayID) -> DisplaySummary? {
        guard CGDisplayIsOnline(displayID) != 0 else { return nil }

        let isBuiltIn = CGDisplayIsBuiltin(displayID) != 0
        let fallbackName = isBuiltIn ? "Écran intégré" : "Écran externe"

        return DisplaySummary(
            identifier: identifier(for: displayID),
            name: localizedName(for: displayID) ?? fallbackName,
            isBuiltIn: isBuiltIn
        )
    }

    private func identifier(for displayID: CGDirectDisplayID) -> DisplayIdentifier {
        guard let unmanagedUUID = ColorSync.CGDisplayCreateUUIDFromDisplayID(displayID) else {
            return DisplayIdentifier(rawValue: "coregraphics-\(displayID)")
        }

        let uuid = unmanagedUUID.takeRetainedValue()
        let uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuid) as String
        return DisplayIdentifier(rawValue: uuidString.lowercased())
    }

    private func localizedName(for displayID: CGDirectDisplayID) -> String? {
        let screenNumberKey = NSDeviceDescriptionKey("NSScreenNumber")

        return NSScreen.screens.first { screen in
            guard let screenNumber = screen.deviceDescription[screenNumberKey] as? NSNumber else {
                return false
            }
            return screenNumber.uint32Value == displayID
        }?.localizedName
    }
}

final class CoreGraphicsDisplayReconfigurationObserver: DisplayReconfigurationObserving {
    private let lock = NSLock()
    private var handler: (@Sendable (CGDirectDisplayID, CGDisplayChangeSummaryFlags) -> Void)?
    private var isRegistered = false

    deinit {
        unregister()
    }

    func register(
        handler: @escaping @Sendable (CGDirectDisplayID, CGDisplayChangeSummaryFlags) -> Void
    ) throws {
        lock.lock()
        self.handler = handler
        lock.unlock()

        let result = CGDisplayRegisterReconfigurationCallback(
            displayReconfigurationCallback,
            Unmanaged.passUnretained(self).toOpaque()
        )

        guard result == .success else {
            lock.lock()
            self.handler = nil
            lock.unlock()
            throw DisplayWatcherError.callbackRegistrationFailed(code: result.rawValue)
        }

        lock.lock()
        isRegistered = true
        lock.unlock()
    }

    func unregister() {
        lock.lock()
        let shouldUnregister = isRegistered
        isRegistered = false
        handler = nil
        lock.unlock()

        guard shouldUnregister else { return }
        CGDisplayRemoveReconfigurationCallback(
            displayReconfigurationCallback,
            Unmanaged.passUnretained(self).toOpaque()
        )
    }

    fileprivate func handle(
        displayID: CGDirectDisplayID,
        flags: CGDisplayChangeSummaryFlags
    ) {
        lock.lock()
        let handler = handler
        lock.unlock()

        handler?(displayID, flags)
    }
}

private let displayReconfigurationCallback: CGDisplayReconfigurationCallBack = {
    displayID,
    flags,
    userInfo in
    guard let userInfo else { return }

    let observer = Unmanaged<CoreGraphicsDisplayReconfigurationObserver>
        .fromOpaque(userInfo)
        .takeUnretainedValue()
    observer.handle(displayID: displayID, flags: flags)
}
