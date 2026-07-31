import AppKit
import SwiftUI

struct MenuBarContentView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(model.statusText, systemImage: model.automationEnabled ? "checkmark.circle.fill" : "pause.circle")
                .font(.headline)

            Divider()

            Toggle(
                "Activer l’automatisation",
                isOn: Binding(
                    get: { model.automationEnabled },
                    set: model.setAutomationEnabled
                )
            )

            Divider()

            Button("Quitter CouchMode") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding(14)
        .frame(width: 280)
    }
}
