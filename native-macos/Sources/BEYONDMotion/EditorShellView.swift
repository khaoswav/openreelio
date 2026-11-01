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
                    timeline.frame(height: 250)
                }
            }
        }
        .background(BMColor.canvas)
        .fileImporter(
            isPresented: $showMediaImporter,
            allowedContentTypes: [.movie, .video, .audio],
            allowsMultipleSelection: true
        ) { result in
            if case let .success(urls) = result { appState.importMedia(urls) }
        }
        .task {
            if appState.tracks.isEmpty { await appState.refreshProject() }
        }
    }

    private var topBar: some View {
        HStack(spacing: 14) {
            BrandMark(size: 29)
            VStack(alignment: .leading, spacing: 1) {
                Text("BEYOND-MOTİON")
                    .font(.system(size: 11, weight: .bold, design: .rounded)).tracking(1)
                Text(appState.projectName.isEmpty ? "Project" : appState.projectName)
                    .font(.system(size: 10)).foregroundStyle(BMColor.muted)
            }
            Rectangle().fill(BMColor.line).frame(width: 1, height: 26).padding(.horizontal, 5)
            HStack(spacing: 5) {
                Label("Edit", systemImage: "scissors")
                    .foregroundStyle(.white).padding(.horizontal, 11).padding(.vertical, 7)
                    .background(Color.white.opacity(0.08), in: Capsule())
                Text("Color")
                Text("Audio")
                Text("Export")
            }
            .font(.system(size: 11, weight: .medium)).foregroundStyle(BMColor.muted)
            Spacer()
            if appState.isBusy { ProgressView().controlSize(.small) }
            Button {
                appState.projectURL = nil
            } label: {
                Label("Projects", systemImage: "square.grid.2x2")
                    .font(.system(size: 11, weight: .medium))
            }
            .buttonStyle(.plain).foregroundStyle(BMColor.muted)
            Button {
                showMediaImporter = true
            } label: {
                Label("Import", systemImage: "plus")
                    .font(.system(size: 11, weight: .semibold)).foregroundStyle(.white)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(BMColor.rose, in: RoundedRectangle(cornerRadius: 9))
            }
            .buttonStyle(.plain)
            Button {
                appState.insertSelectedAssetAtEnd()
            } label: {
                Label("Add to timeline", systemImage: "arrow.down.to.line")
                    .font(.system(size: 11, weight: .semibold)).foregroundStyle(.white)
                    .padding(.horizontal, 13).padding(.vertical, 8)
                    .background(BMColor.navy, in: RoundedRectangle(cornerRadius: 9))
            }
            .buttonStyle(.plain).disabled(appState.selectedAsset == nil || appState.videoTrack == nil)
        }
        .padding(.horizontal, 18).frame(height: 58)
        .background(.ultraThinMaterial)
        .overlay(alignment: .bottom) { Rectangle().fill(BMColor.line).frame(height: 1) }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionEyebrow(title: "Library").padding(.horizontal, 12).padding(.top, 8)
            VStack(spacing: 5) {
                ForEach(EditorPanel.allCases) { panel in
                    Button { activePanel = panel } label: {
                        HStack(spacing: 11) {
                            Image(systemName: panel.symbol).font(.system(size: 14, weight: .medium)).frame(width: 20)
                            Text(panel.rawValue).font(.system(size: 12, weight: .medium))
                            Spacer()
                            if panel == .media {
                                Text("\(appState.mediaAssets.count)")
                                    .font(.system(size: 10, weight: .semibold).monospacedDigit()).foregroundStyle(BMColor.muted)
                            }
                        }
                        .foregroundStyle(activePanel == panel ? .white : BMColor.muted)
                        .padding(.horizontal, 12).frame(height: 39)
                        .background {
                            if activePanel == panel {
                                RoundedRectangle(cornerRadius: 10).fill(BMColor.rose.opacity(0.16))
                                    .overlay(alignment: .leading) {
                                        Capsule().fill(BMColor.rose).frame(width: 3).padding(.vertical, 8)
                                    }
                            }
                        }
                    }.buttonStyle(.plain)
                }
            }
            Rectangle().fill(BMColor.line).frame(height: 1)
            HStack {
                SectionEyebrow(title: activePanel == .media ? "Project media" : activePanel.rawValue)
                Spacer()
                if activePanel == .media {
                    Button { showMediaImporter = true } label: {
                        Image(systemName: "plus").font(.system(size: 11, weight: .bold)).foregroundStyle(BMColor.blue)
                    }.buttonStyle(.plain)
                }
            }.padding(.horizontal, 12)

            if activePanel == .media {
                if appState.mediaAssets.isEmpty {
                    VStack(spacing: 9) {
                        Image(systemName: "film.stack").font(.system(size: 23, weight: .light)).foregroundStyle(BMColor.muted)
                        Text("No media yet").font(.system(size: 11, weight: .medium)).foregroundStyle(BMColor.muted)
                        Button("Import media") { showMediaImporter = true }
                            .font(.system(size: 10, weight: .semibold)).foregroundStyle(BMColor.blue).buttonStyle(.plain)
                    }.frame(maxWidth: .infinity).padding(.top, 28)
                } else {
                    ScrollView {
                        VStack(spacing: 5) {
                            ForEach(appState.mediaAssets) { asset in
                                Button { appState.selectAsset(asset) } label: {
                                    HStack(spacing: 9) {
                                        Image(systemName: asset.kind.localizedCaseInsensitiveContains("audio") ? "waveform" : "film")
                                            .font(.system(size: 13)).foregroundStyle(BMColor.blue)
                                            .frame(width: 30, height: 30).background(BMColor.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(asset.name).font(.system(size: 10, weight: .medium)).foregroundStyle(.white).lineLimit(1)
                                            Text(asset.fileType.isEmpty ? asset.kind.uppercased() : asset.fileType)
                                                .font(.system(size: 8, weight: .bold)).tracking(0.8).foregroundStyle(BMColor.muted)
                                        }
                                        Spacer(minLength: 0)
                                        if let duration = asset.duration {
                                            Text(String(format: "%.1fs", duration))
                                                .font(.system(size: 8, design: .monospaced)).foregroundStyle(BMColor.muted)
                                        }
                                    }
                                    .padding(7)
                                    .background(appState.selectedAssetID == asset.id ? Color.white.opacity(0.07) : .clear,
                                                in: RoundedRectangle(cornerRadius: 9))
                                }.buttonStyle(.plain)
                            }
                        }
                    }
                }
            } else {
                Text("Native \(activePanel.rawValue.lowercased()) tools are being connected to the Rust engine.")
                    .font(.system(size: 10)).foregroundStyle(BMColor.muted).lineSpacing(3).padding(.horizontal, 12)
            }

            Spacer(minLength: 0)
            HStack(spacing: 7) {
                Circle().fill(Color.green).frame(width: 6, height: 6)
                Text("RUST CORE CONNECTED").font(.system(size: 8, weight: .bold)).tracking(1).foregroundStyle(BMColor.muted)
            }.padding(.horizontal, 12).padding(.bottom, 8)
        }
        .padding(12).frame(width: 224).background(BMColor.panel.opacity(0.72))
    }

    private var viewer: some View {
        VStack(spacing: 0) {
            HStack {
                SectionEyebrow(title: "Viewer")
                Spacer()
                Text(appState.selectedAsset?.name ?? "Preview")
                    .font(.system(size: 10, weight: .medium)).foregroundStyle(BMColor.muted).lineLimit(1)
            }.padding(.horizontal, 18).padding(.vertical, 13)
            ZStack {
                RoundedRectangle(cornerRadius: 14).fill(Color.black.opacity(0.62))
                if let player = appState.player, appState.selectedAsset != nil {
                    VideoPlayer(player: player).clipShape(RoundedRectangle(cornerRadius: 12)).padding(8)
                } else {
                    VStack(spacing: 13) {
                        ZStack {
                            Circle().fill(BMColor.navy.opacity(0.32)).frame(width: 82, height: 82)
                            Image(systemName: "play.rectangle").font(.system(size: 30, weight: .light)).foregroundStyle(BMColor.blue)
                        }
                        Text("Your canvas starts here").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white.opacity(0.85))
                        Text("Import media, select it, then add it to your timeline.")
                            .font(.system(size: 11)).foregroundStyle(BMColor.muted)
                        Button { showMediaImporter = true } label: {
                            Label("Import media", systemImage: "plus").font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.white).padding(.horizontal, 14).padding(.vertical, 9)
                                .background(BMColor.rose, in: Capsule())
                        }.buttonStyle(.plain)
                    }
                }
            }
            .aspectRatio(16 / 9, contentMode: .fit).frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 24).padding(.bottom, 20)
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(BMColor.canvas)
    }

    private var inspector: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionEyebrow(title: "Inspector").padding(.top, 8)
            if let asset = appState.selectedAsset {
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(colors: [BMColor.navy.opacity(0.65), BMColor.blue.opacity(0.18)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 104)
                        .overlay { Image(systemName: "film").font(.system(size: 26, weight: .light)).foregroundStyle(.white.opacity(0.8)) }
                    Text(asset.name).font(.system(size: 12, weight: .semibold)).foregroundStyle(.white).lineLimit(2)
                    Text(asset.kind.uppercased()).font(.system(size: 9, weight: .bold)).tracking(1).foregroundStyle(BMColor.blue)
                    Rectangle().fill(BMColor.line).frame(height: 1)
                    inspectorRow("Format", value: asset.fileType.isEmpty ? "Unknown" : asset.fileType)
                    inspectorRow("Duration", value: asset.duration.map { String(format: "%.2f sec", $0) } ?? "Not measured")
                    inspectorRow("Location", value: asset.url.deletingLastPathComponent().lastPathComponent)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "slider.horizontal.3").font(.system(size: 23, weight: .light)).foregroundStyle(BMColor.muted)
                    Text("Nothing selected").font(.system(size: 12, weight: .semibold))
                    Text("Select media to inspect its details.").font(.system(size: 10)).foregroundStyle(BMColor.muted)
                }.padding(.top, 20)
            }
            Spacer()
            Text("NATIVE INSPECTOR").font(.system(size: 8, weight: .bold)).tracking(1.2).foregroundStyle(BMColor.muted.opacity(0.65))
        }.padding(16).frame(width: 246).background(BMColor.panel.opacity(0.58))
    }

    private func inspectorRow(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased()).font(.system(size: 8, weight: .bold)).tracking(1).foregroundStyle(BMColor.muted)
            Text(value).font(.system(size: 10, weight: .medium)).foregroundStyle(.white.opacity(0.85)).lineLimit(1)
        }
    }

    private var timeline: some View {
        VStack(spacing: 0) {
            HStack {
                SectionEyebrow(title: "Timeline")
                Text("Sequence").font(.system(size: 10, weight: .medium)).foregroundStyle(BMColor.muted)
                Spacer()
                Text("\(appState.clips.count) clips")
                    .font(.system(size: 10, weight: .medium, design: .monospaced)).foregroundStyle(BMColor.blue)
                Button { appState.splitSelectedClip() } label: {
                    Label("Split", systemImage: "scissors").font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(appState.selectedClip == nil ? BMColor.muted : BMColor.blue)
                }.buttonStyle(.plain).disabled(appState.selectedClip == nil)
                Button { appState.removeSelectedClip() } label: {
                    Image(systemName: "trash").font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(appState.selectedClip == nil ? BMColor.muted : BMColor.rose)
                }.buttonStyle(.plain).disabled(appState.selectedClip == nil)
                Button { appState.undo() } label: {
                    Image(systemName: "arrow.uturn.backward").font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white).frame(width: 25, height: 25)
                        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 7))
                }.buttonStyle(.plain).keyboardShortcut("z", modifiers: .command)
                Button { appState.redo() } label: {
                    Image(systemName: "arrow.uturn.forward").font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white).frame(width: 25, height: 25)
                        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 7))
                }.buttonStyle(.plain).keyboardShortcut("z", modifiers: [.command, .shift])
                Button { Task { await appState.refreshProject() } } label: {
                    Image(systemName: "arrow.clockwise").font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white).frame(width: 25, height: 25)
                        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 7))
                }.buttonStyle(.plain)
            }.padding(.horizontal, 17).frame(height: 43)
            Rectangle().fill(BMColor.line).frame(height: 1)
            HStack(spacing: 10) {
                Image(systemName: "playhead").font(.system(size: 10, weight: .semibold)).foregroundStyle(BMColor.rose)
                Text("PLAYHEAD").font(.system(size: 8, weight: .bold)).tracking(1).foregroundStyle(BMColor.muted)
                Slider(value: $appState.playheadSeconds, in: 0...appState.timelineDuration, step: 0.1)
                    .tint(BMColor.rose)
                Text(String(format: "%.1fs", appState.playheadSeconds))
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white).frame(width: 48, alignment: .trailing)
            }
            .padding(.horizontal, 14).frame(height: 34)
            Rectangle().fill(BMColor.line).frame(height: 1)

            if appState.tracks.isEmpty {
                VStack(spacing: 7) {
                    Image(systemName: "rectangle.split.3x1").font(.system(size: 19)).foregroundStyle(BMColor.muted)
                    Text("No timeline tracks").font(.system(size: 10, weight: .medium)).foregroundStyle(BMColor.muted)
                    Text("Import media and create a sequence track in the next editing pass.")
                        .font(.system(size: 9)).foregroundStyle(BMColor.muted.opacity(0.75))
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Text("TRACKS").font(.system(size: 8, weight: .bold)).tracking(1).foregroundStyle(BMColor.muted)
                            .frame(height: 28)
                        ForEach(appState.tracks) { track in
                            HStack(spacing: 7) {
                                Image(systemName: track.kind.localizedCaseInsensitiveContains("audio") ? "waveform" : "film")
                                    .font(.system(size: 10)).foregroundStyle(track.kind.localizedCaseInsensitiveContains("audio") ? BMColor.blue : BMColor.rose)
                                Text(track.name).font(.system(size: 9, weight: .semibold)).foregroundStyle(BMColor.muted).lineLimit(1)
                                Spacer(minLength: 0)
                                Text("\(track.clipCount)").font(.system(size: 8, design: .monospaced)).foregroundStyle(BMColor.muted.opacity(0.7))
                            }
                            .padding(.horizontal, 10).frame(height: 48)
                            .overlay(alignment: .bottom) { Rectangle().fill(BMColor.line).frame(height: 1) }
                        }
                    }.frame(width: 118)

                    ScrollView(.horizontal) {
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                ForEach(0..<12, id: \.self) { tick in
                                    Text(String(format: "%02d:%02d", tick / 6, (tick % 6) * 10))
                                        .font(.system(size: 8, design: .monospaced)).foregroundStyle(BMColor.muted)
                                        .frame(width: 90, alignment: .leading)
                                }
                            }.padding(.leading, 12).frame(height: 28)
                            ForEach(appState.tracks) { track in
                                ZStack(alignment: .leading) {
                                    Rectangle().fill(Color.white.opacity(0.018))
                                    ForEach(appState.clips.filter { $0.trackId == track.id }) { clip in
                                        Button {
                                            appState.selectClip(clip)
                                        } label: {
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(track.kind.localizedCaseInsensitiveContains("audio") ? BMColor.navy.opacity(0.88) : BMColor.rose.opacity(0.62))
                                                .frame(width: max(CGFloat(clip.durationSec * 45), 24), height: 32)
                                                .overlay(alignment: .leading) {
                                                    Text(appState.mediaAssets.first(where: { $0.id == clip.assetId })?.name ?? "Clip")
                                                        .font(.system(size: 8, weight: .medium)).foregroundStyle(.white)
                                                        .lineLimit(1).padding(.horizontal, 7)
                                                }
                                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(
                                                    appState.selectedClipID == clip.id ? BMColor.blue : Color.white.opacity(0.16),
                                                    lineWidth: appState.selectedClipID == clip.id ? 2 : 1
                                                ))
                                        }
                                        .buttonStyle(.plain)
                                        .padding(.leading, CGFloat(max(clip.timelineInSec, 0) * 45) + 12)
                                        .contextMenu {
                                            Button("Split at playhead") { appState.selectClip(clip); appState.splitSelectedClip() }
                                            Button("Remove clip", role: .destructive) { appState.selectClip(clip); appState.removeSelectedClip() }
                                        }
                                    }
                                }
                                .frame(height: 48)
                                .overlay(alignment: .bottom) { Rectangle().fill(BMColor.line).frame(height: 1) }
                            }
                        }
                        .frame(minWidth: 1080, alignment: .leading)
                    }
                }
            }
        }.background(BMColor.panel.opacity(0.72))
    }
}
