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

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionEyebrow(title: "Workspace")
                            Text(appState.workspaceURL?.lastPathComponent ?? "Creative space")
                                .font(.system(size: 38, weight: .semibold, design: .rounded))
                            Text("Your projects stay on this Mac. Open an existing edit or start a new one.")
                                .font(.system(size: 13)).foregroundStyle(BMColor.muted)
                        }

                        GlassPanel(padding: 24) {
                            VStack(alignment: .leading, spacing: 16) {
                                Label("New project", systemImage: "plus.square").font(.system(size: 14, weight: .semibold))
                                TextField("Project name", text: $projectName)
                                    .textFieldStyle(.roundedBorder).frame(maxWidth: 360)
                                Button {
                                    Task { await appState.createProject(named: projectName) }
                                } label: {
                                    HStack {
                                        if appState.isBusy { ProgressView().controlSize(.small) }
                                        Text("Create project")
                                        Image(systemName: "arrow.right")
                                    }
                                    .font(.system(size: 12, weight: .semibold)).foregroundStyle(.white)
                                    .padding(.horizontal, 17).padding(.vertical, 11)
                                    .background(BMColor.rose, in: RoundedRectangle(cornerRadius: 10))
                                }
                                .buttonStyle(.plain).disabled(appState.isBusy)
                            }
                        }
                        .frame(maxWidth: 480, alignment: .leading)

                        VStack(alignment: .leading, spacing: 13) {
                            HStack {
                                SectionEyebrow(title: "Existing projects")
                                Spacer()
                                Text("\(appState.availableProjects.count)")
                                    .font(.system(size: 10, weight: .semibold, design: .rounded)).foregroundStyle(BMColor.muted)
                            }
                            if appState.availableProjects.isEmpty {
                                Text("Projects you create here will appear in this list.")
                                    .font(.system(size: 11)).foregroundStyle(BMColor.muted)
                            } else {
                                ForEach(appState.availableProjects, id: \.path) { project in
                                    Button { appState.openProject(project) } label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: "film.stack")
                                                .font(.system(size: 16)).foregroundStyle(BMColor.blue)
                                                .frame(width: 38, height: 38)
                                                .background(BMColor.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text(project.lastPathComponent).font(.system(size: 12, weight: .semibold)).foregroundStyle(.white)
                                                Text("Local project").font(.system(size: 9)).foregroundStyle(BMColor.muted)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right").font(.system(size: 10, weight: .bold)).foregroundStyle(BMColor.muted)
                                        }
                                        .padding(12)
                                        .background(Color.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 13))
                                        .overlay(RoundedRectangle(cornerRadius: 13).stroke(BMColor.line, lineWidth: 1))
                                    }.buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }

                Text("PROJECTS ARE STORED LOCALLY ON THIS MAC")
                    .font(.system(size: 9, weight: .bold)).tracking(1.5).foregroundStyle(BMColor.muted)
            }
            .padding(56).frame(maxWidth: 1100, maxHeight: 780, alignment: .leading)
        }
    }
}
