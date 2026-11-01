import SwiftUI

@main
struct BEYONDMotionApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .frame(minWidth: 1180, minHeight: 760)
                .preferredColorScheme(.dark)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact)
        .defaultSize(width: 1480, height: 940)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Open Workspace…") {
                    appState.isWorkspacePickerPresented = true
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
            }
        }
    }
}
