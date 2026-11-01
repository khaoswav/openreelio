import SwiftUI
import UniformTypeIdentifiers

struct WorkspaceWelcomeView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isImporterPresented = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [BMColor.canvas, Color(red: 0.075, green: 0.085, blue: 0.13), BMColor.canvas],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(BMColor.rose.opacity(0.12))
                .frame(width: 460, height: 460)
                .blur(radius: 110)
                .offset(x: 380, y: -260)

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 12) {
                        BrandMark(size: 42)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("BEYOND-MOTİON")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .tracking(1.2)
                            Text("CREATIVE STUDIO")
                                .font(.system(size: 9, weight: .semibold))
                                .tracking(2.4)
                                .foregroundStyle(BMColor.muted)
                        }
                    }

                    Spacer()

                    SectionEyebrow(title: "Your creative space")
                        .padding(.bottom, 18)

                    Text("Make room\nfor the\nunexpected.")
                        .font(.system(size: 58, weight: .semibold, design: .rounded))
                        .tracking(-2.6)
                        .lineSpacing(-3)
                        .foregroundStyle(.white)

                    Text("A focused home for your video projects,\nideas and next great cut.")
                        .font(.system(size: 16))
                        .lineSpacing(6)
                        .foregroundStyle(.white.opacity(0.58))
                        .padding(.top, 22)

                    Button {
                        isImporterPresented = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "folder.badge.plus")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Open Workspace")
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12, weight: .bold))
                                .opacity(0.8)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .frame(width: 252, height: 54)
                        .background(
                            LinearGradient(colors: [BMColor.rose, Color(red: 0.73, green: 0.16, blue: 0.34)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: RoundedRectangle(cornerRadius: 15, style: .continuous)
                        )
                        .shadow(color: BMColor.rose.opacity(0.25), radius: 22, y: 9)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 34)

                    Text("Choose a folder on your Mac to use as a workspace.")
                        .font(.system(size: 11))
                        .foregroundStyle(BMColor.muted)
                        .padding(.top, 12)

                    Spacer()
                    Text("BUILT FOR THE CREATIVE PROCESS")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.25))
                }
                .padding(.leading, 76)
                .padding(.vertical, 58)
                .frame(maxWidth: .infinity, alignment: .leading)

                Rectangle()
                    .fill(LinearGradient(colors: [.clear, BMColor.line, .clear], startPoint: .top, endPoint: .bottom))
                    .frame(width: 1)
                    .padding(.vertical, 74)

                VStack(alignment: .leading, spacing: 22) {
                    HStack {
                        SectionEyebrow(title: "Recent workspaces")
                        Spacer()
                        Text("\(appState.recentWorkspaces.count)")
                            .font(.system(size: 11, weight: .semibold, design: .rounded).monospacedDigit())
                            .foregroundStyle(BMColor.muted)
                    }

                    if appState.recentWorkspaces.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 27, weight: .light))
                                .foregroundStyle(BMColor.blue)
                            Text("Nothing here yet")
                                .font(.system(size: 17, weight: .semibold))
                            Text("The workspaces you open will appear here for quick access.")
                                .font(.system(size: 12))
                                .lineSpacing(4)
                                .foregroundStyle(BMColor.muted)
                                .frame(maxWidth: 250, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(appState.recentWorkspaces, id: \.path) { url in
                                Button {
                                    appState.openRecentWorkspace(url)
                                } label: {
                                    HStack(spacing: 13) {
                                        Image(systemName: "folder.fill")
                                            .font(.system(size: 18))
                                            .foregroundStyle(BMColor.blue)
                                            .frame(width: 38, height: 38)
                                            .background(BMColor.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 11))
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(url.lastPathComponent)
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundStyle(.white)
                                                .lineLimit(1)
                                            Text(url.deletingLastPathComponent().path)
                                                .font(.system(size: 10))
                                                .foregroundStyle(BMColor.muted)
                                                .lineLimit(1)
                                        }
                                        Spacer(minLength: 4)
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(BMColor.muted)
                                    }
                                    .padding(11)
                                    .background(Color.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 14))
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(BMColor.line, lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Spacer()
                    HStack(spacing: 7) {
                        Circle().fill(Color.green).frame(width: 6, height: 6)
                        Text("LOCAL WORKSPACE")
                            .font(.system(size: 9, weight: .bold))
                            .tracking(1.5)
                            .foregroundStyle(BMColor.muted)
                    }
                }
                .padding(.horizontal, 42)
                .padding(.vertical, 74)
                .frame(width: 390, alignment: .leading)
            }
            .frame(maxWidth: 1240, maxHeight: 740)
        }
        .fileImporter(
            isPresented: $isImporterPresented,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            if case let .success(urls) = result, let url = urls.first {
                appState.openWorkspace(url)
            }
        }
    }
}
