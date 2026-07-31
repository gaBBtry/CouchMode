import Foundation

protocol AutomationPreferencesStoring: AnyObject {
    var automationEnabled: Bool { get set }
}

final class UserDefaultsAutomationPreferences: AutomationPreferencesStoring {
    private enum Key {
        static let automationEnabled = "automationEnabled"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var automationEnabled: Bool {
        get {
            guard defaults.object(forKey: Key.automationEnabled) != nil else {
                return true
            }

            return defaults.bool(forKey: Key.automationEnabled)
        }
        set {
            defaults.set(newValue, forKey: Key.automationEnabled)
        }
    }
}
