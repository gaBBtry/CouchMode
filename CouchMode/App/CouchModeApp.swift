import SwiftUI

@main
struct CouchModeApp: App {
    @StateObject private var model = AppModel(
        preferences: UserDefaultsAutomationPreferences()
    )

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView(model: model)
        } label: {
            Label("CouchMode", systemImage: model.automationEnabled ? "gamecontroller.fill" : "gamecontroller")
        }
        .menuBarExtraStyle(.window)
    }
}
