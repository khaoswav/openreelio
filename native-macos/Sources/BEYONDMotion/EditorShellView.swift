import AVKit
import SwiftUI
import UniformTypeIdentifiers

private enum EditorPanel: String, CaseIterable, Identifiable {
    case media = "Media"
    case titles = "Titles"
    case effects = "Effects"
    case audio = "Audio"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .media: "square.stack.3d.up"
        case .titles: "textformat"
        case .effects: "sparkles"
        case .audio: "waveform"
        }
    }
}

struct EditorShellView: View {
    @EnvironmentObject private var appState: AppState
    @State private var activePanel: EditorPanel = .media
    @State private var showMediaImporter = false

    var body: some View {
        VStack(spacing: 0) {
            topBar

            HStack(spacing: 0) {
                sidebar
                Rectangle().fill(BMColor.line).frame(width: 1)

                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        viewer
                        Rectangle().fill(BMColor.line).frame(width: 1)
                        inspector
                    }
                    .frame(maxHeight: .infinity)

                    Rectangle().fill(BMColor.line).frame(height: 1)
                    timeline
                        .frame(height: 238)
                }
            }
        }
        .background(BMColor.canvas)
        .fileImporter(
            isPresented: $showMediaImporter,
            allowedContentTypes: [.movie, .video, .audio],
            allowsMultipleSelection: true
        ) { result in
            if case let .success(urls) = result {
                appState.importMedia(urls)
            }
        }
    }

    private var topBar: some View {
        HStack(spacing: 14) {
            BrandMark(size: 29)
            VStack(alignment: .leading, spacing: 1) {
                Text("BEYOND-MOTİON")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1)
                Text(appState.workspaceURL?.lastPathComponent ?? "Workspace")
                    .font(.system(size: 10))
                    .foregroundStyle(BMColor.muted)
            }

            Rectangle().fill(BMColor.line).frame(width: 1, height: 26).padding(.horizontal, 5)

            HStack(spacing: 5) {
                Label("Edit", systemImage: "scissors")
                    .foregroundStyle(.white)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(Color.white.opacity(0.08), in: Capsule())
                Text("Color")
                Text("Audio")
                Text("Export")
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(BMColor.muted)

            Spacer()

            Button {
                appState.isWorkspacePickerPresented = true
            } label: {
                Label("Switch Workspace", systemImage: "folder")
                    .font(.system(size: 11, weight: .medium))
            }
            .buttonStyle(.plain)
            .foregroundStyle(BMColor.muted)

            Button {
                showMediaImporter = true
            } label: {
                Label("Import", systemImage: "plus")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(BMColor.rose, in: RoundedRectangle(cornerRadius: 9))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .frame(height: 58)
        .background(.ultraThinMaterial)
        .overlay(alignment: .bottom) { Rectangle().fill(BMColor.line).frame(height: 1) }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionEyebrow(title: "Library")
                .padding(.horizontal, 12)
                .padding(.top, 8)

            VStack(spacing: 5) {
                ForEach(EditorPanel.allCases) { panel in
                    Button {
                        activePanel = panel
                    } label: {
                        HStack(spacing: 11) {
                            Image(systemName: panel.symbol)
                                .font(.system(size: 14, weight: .medium))
                                .frame(width: 20)
                            Text(panel.rawValue)
                                .font(.system(size: 12, weight: .medium))
                            Spacer()
                            if panel == .media {
                                Text("\(appState.mediaAssets.count)")
                                    .font(.system(size: 10, weight: .semibold).monospacedDigit())
                                    .foregroundStyle(BMColor.muted)
                            }
                        }
                        .foregroundStyle(activePanel == panel ? .white : BMColor.muted)
                        .padding(.horizontal, 12)
                        .frame(height: 39)
                        .background {
                            if activePanel == panel {
                                RoundedRectangle(cornerRadius: 10).fill(BMColor.rose.opacity(0.16))
                                    .overlay(alignment: .leading) {
                                        Capsule().fill(BMColor.rose).frame(width: 3).padding(.vertical, 8)
                                    }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            Rectangle().fill(BMColor.line).frame(height: 1)

            HStack {
                SectionEyebrow(title: activePanel == .media ? "Project media" : activePanel.rawValue)
                Spacer()
                if activePanel == .media {
                    Button { showMediaImporter = true } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(BMColor.blue)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)

            if activePanel == .media {
                if appState.mediaAssets.isEmpty {
                    VStack(spacing: 9) {
                        Image(systemName: "film.stack")
                            .font(.system(size: 23, weight: .light))
                            .foregroundStyle(BMColor.muted)
                        Text("No media yet")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(BMColor.muted)
                        Button("Import media") { showMediaImporter = true }
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(BMColor.blue)
                            .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 28)
                } else {
                    ScrollView {
                        VStack(spacing: 5) {
                            ForEach(appState.mediaAssets) { asset in
                                Button {
                                    appState.selectAsset(asset)
                                } label: {
                                    HStack(spacing: 9) {
                                        Image(systemName: asset.fileType == "MP3" || asset.fileType == "WAV" ? "waveform" : "film")
                                            .font(.system(size: 13))
                                            .foregroundStyle(BMColor.blue)
                                            .frame(width: 30, height: 30)
                                            .background(BMColor.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(asset.name)
                                                .font(.system(size: 10, weight: .medium))
                                                .foregroundStyle(.white)
                                                .lineLimit(1)
                                            Text(asset.fileType.isEmpty ? "MEDIA" : asset.fileType)
                                                .font(.system(size: 8, weight: .bold))
                                                .tracking(0.8)
                                                .foregroundStyle(BMColor.muted)
                                        }
                                        Spacer(minLength: 0)
                                    }
                                    .padding(7)
                                    .background(appState.selectedAssetID == asset.id ? Color.white.opacity(0.07) : .clear,
                                                in: RoundedRectangle(cornerRadius: 9))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            } else {
                Text("This native panel is being built in stages.")
                    .font(.system(size: 10))
                    .foregroundStyle(BMColor.muted)
                    .lineSpacing(3)
                    .padding(.horizontal, 12)
            }

            Spacer(minLength: 0)
            HStack(spacing: 7) {
                Circle().fill(Color.green).frame(width: 6, height: 6)
                Text("LOCAL PROJECT")
                    .font(.system(size: 8, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(BMColor.muted)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
        .padding(12)
        .frame(width: 224)
        .background(BMColor.panel.opacity(0.72))
    }

    private var viewer: some View {
        VStack(spacing: 0) {
            HStack {
                SectionEyebrow(title: "Viewer")
                Spacer()
                Text(appState.selectedAsset?.name ?? "Preview")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(BMColor.muted)
                    .lineLimit(1)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 13)

            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.black.opacity(0.62))
                if let player = appState.player, appState.selectedAsset != nil {
                    VideoPlayer(player: player)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(8)
                } else {
                    VStack(spacing: 13) {
                        ZStack {
                            Circle().fill(BMColor.navy.opacity(0.32)).frame(width: 82, height: 82)
                            Image(systemName: "play.rectangle")
                                .font(.system(size: 30, weight: .light))
                                .foregroundStyle(BMColor.blue)
                        }
                        Text("Your canvas starts here")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.85))
                        Text("Import a video or audio file to preview it.")
                            .font(.system(size: 11))
                            .foregroundStyle(BMColor.muted)
                        Button { showMediaImporter = true } label: {
                            Label("Import media", systemImage: "plus")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .background(BMColor.rose, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .aspectRatio(16 / 9, contentMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BMColor.canvas)
    }

    private var inspector: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionEyebrow(title: "Inspector")
                .padding(.top, 8)

            if let asset = appState.selectedAsset {
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(colors: [BMColor.navy.opacity(0.65), BMColor.blue.opacity(0.18)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 104)
                        .overlay {
                            Image(systemName: "film")
                                .font(.system(size: 26, weight: .light))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    Text(asset.name)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    Text(asset.fileType.isEmpty ? "MEDIA FILE" : asset.fileType)
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(BMColor.blue)
                    Rectangle().fill(BMColor.line).frame(height: 1)
                    inspectorRow("Location", value: asset.url.deletingLastPathComponent().lastPathComponent)
                    inspectorRow("Format", value: asset.fileType.isEmpty ? "Unknown" : asset.fileType)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 23, weight: .light))
                        .foregroundStyle(BMColor.muted)
                    Text("Nothing selected")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Select media to see its details.")
                        .font(.system(size: 10))
                        .foregroundStyle(BMColor.muted)
                }
                .padding(.top, 20)
            }

            Spacer()
            Text("NATIVE INSPECTOR")
                .font(.system(size: 8, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(BMColor.muted.opacity(0.65))
        }
        .padding(16)
        .frame(width: 246)
        .background(BMColor.panel.opacity(0.58))
    }

    private func inspectorRow(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 8, weight: .bold))
                .tracking(1)
                .foregroundStyle(BMColor.muted)
            Text(value)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.85))
                .lineLimit(1)
        }
    }

    private var timeline: some View {
        VStack(spacing: 0) {
            HStack {
                SectionEyebrow(title: "Timeline")
                Text("Sequence 01")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(BMColor.muted)
                Spacer()
                Text("00:00:00:00")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(BMColor.blue)
                Button { showMediaImporter = true } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 25, height: 25)
                        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 7))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 17)
            .frame(height: 43)

            Rectangle().fill(BMColor.line).frame(height: 1)

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(["VIDEO 01", "VIDEO 02", "AUDIO 01"], id: \.self) { name in
                        HStack(spacing: 8) {
                            Image(systemName: name.contains("AUDIO") ? "waveform" : "film")
                                .font(.system(size: 10))
                                .foregroundStyle(name.contains("AUDIO") ? BMColor.blue : BMColor.rose)
                            Text(name)
                                .font(.system(size: 8, weight: .bold))
                                .tracking(0.7)
                                .foregroundStyle(BMColor.muted)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 48)
                        Rectangle().fill(BMColor.line).frame(height: 1)
                    }
                }
                .frame(width: 118)

                VStack(spacing: 0) {
                    HStack {
                        ForEach(["00:00", "00:10", "00:20", "00:30", "00:40", "00:50"], id: \.self) { tick in
                            Text(tick)
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundStyle(BMColor.muted)
                            Spacer(minLength: 8)
                        }
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 25)

                    ForEach(0..<3, id: \.self) { row in
                        ZStack(alignment: .leading) {
                            Rectangle().fill(Color.white.opacity(0.018))
                            if row == 0, !appState.mediaAssets.isEmpty {
                                HStack(spacing: 4) {
                                    ForEach(appState.mediaAssets.prefix(3)) { asset in
                                        Text(asset.name)
                                            .font(.system(size: 9, weight: .medium))
                                            .foregroundStyle(.white)
                                            .lineLimit(1)
                                            .padding(.horizontal, 10)
                                            .frame(width: 150, height: 34, alignment: .leading)
                                            .background(BMColor.rose.opacity(0.42), in: RoundedRectangle(cornerRadius: 6))
                                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(BMColor.rose.opacity(0.65), lineWidth: 1))
                                    }
                                }
                                .padding(.leading, 12)
                            } else if row == 2 && !appState.mediaAssets.isEmpty {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(BMColor.navy.opacity(0.65))
                                    .frame(width: 205, height: 30)
                                    .overlay(alignment: .leading) {
                                        HStack(spacing: 2) {
                                            ForEach(0..<22, id: \.self) { index in
                                                Capsule().fill(BMColor.blue.opacity(0.65)).frame(width: 2, height: CGFloat((index * 7) % 13 + 5))
                                            }
                                        }
                                        .padding(.horizontal, 8)
                                    }
                                    .padding(.leading, 12)
                            }
                            Rectangle().fill(BMColor.line).frame(height: 1).offset(y: 23.5)
                        }
                        .frame(height: 48)
                    }
                }
                .overlay(alignment: .leading) {
                    Rectangle().fill(BMColor.rose).frame(width: 1.5).padding(.top, 25)
                        .shadow(color: BMColor.rose.opacity(0.8), radius: 5)
                        .padding(.leading, 84)
                }
            }
        }
        .background(BMColor.panel.opacity(0.72))
    }
}
