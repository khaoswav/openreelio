import SwiftUI

struct WorkspaceDashboardView: View {
    @EnvironmentObject private var appState: AppState
    @State private var projectName = "My First Project"

    var body: some View {
        ZStack {
            BMColor.canvas.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 26) {
                HStack(spacing: 12) {
                    BrandMark(size: 38)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("BEYOND-MOTİON").font(.system(size: 14, weight: .bold, design: .rounded)).tracking(1)
                        Text("WORKSPACE").font(.system(size: 9, weight: .bold)).tracking(2).foregroundStyle(BMColor.muted)
                    }
                    Spacer()
                    Button("Switch Workspace") { appState.isWorkspacePickerPresented = true }
                        .buttonStyle(.bordered).tint(BMColor.blue)
                }

                Spacer()
                SectionEyebrow(title: "Workspace")
                Text(appState.workspaceURL?.lastPathComponent ?? "Creative space")
                    .font(.system(size: 38, weight: .semibold, design: .rounded))
                Text("Create a project to start editing. The Rust engine will manage the actual project state, media and timeline.")
                    .font(.system(size: 13)).foregroundStyle(BMColor.muted).frame(maxWidth: 560, alignment: .leading)

                GlassPanel(padding: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Label("New project", systemImage: "plus.square")
                            .font(.system(size: 14, weight: .semibold))
                        TextField("Project name", text: $projectName)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 360)
                        Button {
                            Task { await appState.createProject(named: projectName) }
                        } label: {
                            HStack {
                                if appState.isBusy { ProgressView().controlSize(.small) }
                                Text("Create project")
                                Image(systemName: "arrow.right")
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 17).padding(.vertical, 11)
                            .background(BMColor.rose, in: RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        .disabled(appState.isBusy)
                    }
                }
                .frame(maxWidth: 480, alignment: .leading)
                Spacer()
                Text("PROJECTS ARE STORED LOCALLY ON THIS MAC")
                    .font(.system(size: 9, weight: .bold)).tracking(1.5).foregroundStyle(BMColor.muted)
            }
            .padding(64)
            .frame(maxWidth: 1100, maxHeight: 760, alignment: .leading)
        }
    }
}
