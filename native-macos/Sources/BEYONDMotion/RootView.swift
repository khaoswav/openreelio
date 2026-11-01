import SwiftUI
import UniformTypeIdentifiers

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            if appState.workspaceURL != nil {
                EditorShellView()
                    .transition(.opacity.combined(with: .scale(scale: 0.985)))
            } else {
                WorkspaceWelcomeView()
                    .transition(.opacity)
            }
        }
        .background(BMColor.canvas)
        .animation(.smooth(duration: 0.28), value: appState.workspaceURL)
        .fileImporter(
            isPresented: $appState.isWorkspacePickerPresented,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            if case let .success(urls) = result, let url = urls.first {
                appState.openWorkspace(url)
            }
        }
    }
}
