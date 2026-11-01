import AVKit
import SwiftUI
import UniformTypeIdentifiers

struct MediaAsset: Identifiable {
    let id: String
    let name: String
    let url: URL
    let duration: Double?
    let kind: String
    var fileType: String { url.pathExtension.uppercased() }
}

@MainActor
final class AppState: ObservableObject {
    @Published var workspaceURL: URL?
    @Published var projectURL: URL?
    @Published var projectName = ""
    @Published var recentWorkspaces: [URL] = []
    @Published var mediaAssets: [MediaAsset] = []
    @Published var tracks: [CLITrack] = []
    @Published var clips: [CLIClip] = []
    @Published var activeSequenceID: String?
    @Published var selectedAssetID: String?
    @Published var selectedClipID: String?
    @Published var playheadSeconds: Double = 0
    @Published var player: AVPlayer?
    @Published var isWorkspacePickerPresented = false
    @Published var isMediaPickerPresented = false
    @Published var isBusy = false
    @Published var errorMessage: String?

    private let cli = RustCLIClient()
    private var activeWorkspaceURL: URL?
    private var scopedMediaURLs: Set<URL> = []

    var selectedAsset: MediaAsset? { mediaAssets.first { $0.id == selectedAssetID } }
    var selectedClip: CLIClip? { clips.first { $0.id == selectedClipID } }
    var timelineDuration: Double { max(clips.map { $0.timelineInSec + $0.durationSec }.max() ?? 0, 30) }
    var videoTrack: CLITrack? { tracks.first { $0.kind.localizedCaseInsensitiveContains("video") } }

    var availableProjects: [URL] {
        guard let workspaceURL else { return [] }
        let root = workspaceURL.appendingPathComponent("Projects", isDirectory: true)
        guard let entries = try? FileManager.default.contentsOfDirectory(
            at: root, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles]
        ) else { return [] }
        return entries.filter {
            FileManager.default.fileExists(atPath: $0.appendingPathComponent(".openreelio/state/project.json").path)
        }.sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
    }

    init() { restoreRecentWorkspaces() }

    func openWorkspace(_ url: URL) {
        if let activeWorkspaceURL { activeWorkspaceURL.stopAccessingSecurityScopedResource() }
        _ = url.startAccessingSecurityScopedResource()
        activeWorkspaceURL = url
        workspaceURL = url
        projectURL = nil
        projectName = ""
        mediaAssets = []
        tracks = []
        clips = []
        player?.pause()
        player = nil

        var recent = recentWorkspaces.filter { $0.standardizedFileURL != url.standardizedFileURL }
        recent.insert(url, at: 0)
        recentWorkspaces = Array(recent.prefix(6))
        persistRecentWorkspaces()
    }

    func openRecentWorkspace(_ url: URL) {
        guard FileManager.default.fileExists(atPath: url.path) else {
            recentWorkspaces.removeAll { $0 == url }
            persistRecentWorkspaces()
            return
        }
        openWorkspace(url)
    }

    func createProject(named rawName: String) async {
        guard let workspaceURL else { return }
        let name = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { errorMessage = "Enter a project name."; return }
        isBusy = true
        defer { isBusy = false }
        do {
            let folder = workspaceURL.appendingPathComponent("Projects", isDirectory: true)
                .appendingPathComponent(name, isDirectory: true)
            let created: CLIProjectCreated = try await cli.runJSON([
                "project", "create", "--name", name, "--path", folder.path
            ])
            projectURL = URL(fileURLWithPath: created.path)
            await refreshProject()
        } catch { errorMessage = error.localizedDescription }
    }

    func openProject(_ url: URL) {
        projectURL = url
        Task { await refreshProject() }
    }

    func refreshProject() async {
        guard let projectURL else { return }
        isBusy = true
        defer { isBusy = false }
        do {
            let info: CLIProjectCreated = try await cli.runJSON(["project", "open", "--path", projectURL.path])
            projectName = info.name
            let assetList: CLIAssetList = try await cli.runJSON(["asset", "list", "--path", projectURL.path])
            mediaAssets = assetList.assets.map {
                MediaAsset(id: $0.id, name: $0.name, url: URL(fileURLWithPath: $0.uri),
                           duration: $0.durationSec, kind: $0.kind)
            }
            let trackList: CLITrackList = try await cli.runJSON(["timeline", "tracks", "--path", projectURL.path])
            tracks = trackList.tracks
            activeSequenceID = trackList.sequenceId
            let clipList: CLIClipList = try await cli.runJSON(["timeline", "clips", "--path", projectURL.path])
            clips = clipList.clips
            if let selectedClipID, !clips.contains(where: { $0.id == selectedClipID }) { self.selectedClipID = nil }
            if let selectedAssetID, !mediaAssets.contains(where: { $0.id == selectedAssetID }) {
                self.selectedAssetID = nil
                player?.pause()
                player = nil
            }
        } catch { errorMessage = error.localizedDescription }
    }

    func importMedia(_ urls: [URL]) {
        guard let projectURL else { errorMessage = "Create or open a project before importing media."; return }
        Task {
            isBusy = true
            defer { isBusy = false }
            do {
                for url in urls {
                    let access = url.startAccessingSecurityScopedResource()
                    if access { scopedMediaURLs.insert(url) }
                    let _: CLIStatusResponse = try await cli.runJSON(
                        ["asset", "import", "--path", projectURL.path, "--file", url.path]
                    )
                }
                await refreshProject()
            } catch { errorMessage = error.localizedDescription }
        }
    }

    func selectAsset(_ asset: MediaAsset) {
        selectedAssetID = asset.id
        player?.pause()
        player = AVPlayer(url: asset.url)
    }

    func insertSelectedAssetAtEnd() {
        guard let projectURL, let asset = selectedAsset, let track = videoTrack else {
            errorMessage = "Select a video asset and make sure the project has a video track."
            return
        }
        let position = clips.filter { $0.trackId == track.id }
            .map { $0.timelineInSec + $0.durationSec }.max() ?? 0
        runProjectCommand(["timeline", "insert", "--path", projectURL.path, "--asset", asset.id,
                           "--track", track.id, "--at", String(position)])
    }


    func selectClip(_ clip: CLIClip) {
        selectedClipID = clip.id
        playheadSeconds = clip.timelineInSec
    }

    func splitSelectedClip() {
        guard let projectURL, let clip = selectedClip else {
            errorMessage = "Select a clip before splitting."
            return
        }
        guard playheadSeconds > clip.timelineInSec + 0.01,
              playheadSeconds < clip.timelineInSec + clip.durationSec - 0.01 else {
            errorMessage = "Move the playhead inside the selected clip to split it."
            return
        }
        runProjectCommand(["timeline", "split", "--path", projectURL.path,
                           "--clip", clip.id, "--track", clip.trackId, "--at", String(playheadSeconds)])
    }

    func removeSelectedClip() {
        guard let projectURL, let clip = selectedClip else {
            errorMessage = "Select a clip to remove."
            return
        }
        selectedClipID = nil
        runProjectCommand(["timeline", "remove", "--path", projectURL.path,
                           "--clip", clip.id, "--track", clip.trackId])
    }

    func moveClip(_ clip: CLIClip, to seconds: Double) {
        guard let projectURL else { return }
        let proposed = max(0, seconds)
        let snapTargets = clips.filter { $0.id != clip.id }.flatMap {
            [$0.timelineInSec, $0.timelineInSec + $0.durationSec]
        }
        let snapped = snapTargets.first(where: { abs($0 - proposed) <= 0.14 }) ?? proposed
        runProjectCommand(["timeline", "move", "--path", projectURL.path,
                           "--clip", clip.id, "--track", clip.trackId, "--to", String(snapped)])
    }

    func trimClip(_ clip: CLIClip, sourceIn: Double? = nil,
                  sourceOut: Double? = nil, timelineIn: Double? = nil) {
        guard let projectURL else { return }
        var arguments = ["timeline", "trim", "--path", projectURL.path,
                         "--clip", clip.id, "--track", clip.trackId]
        if let sourceIn { arguments += ["--in", String(sourceIn)] }
        if let sourceOut { arguments += ["--out", String(sourceOut)] }
        if let timelineIn { arguments += ["--timeline-in", String(timelineIn)] }
        runProjectCommand(arguments)
    }

    func undo() {
        guard let projectURL else { return }
        runProjectCommand(["timeline", "undo", "--path", projectURL.path])
    }

    func redo() {
        guard let projectURL else { return }
        runProjectCommand(["timeline", "redo", "--path", projectURL.path])
    }

    private func runProjectCommand(_ arguments: [String]) {
        Task {
            isBusy = true
            defer { isBusy = false }
            do {
                let _: CLIStatusResponse = try await cli.runJSON(arguments)
                await refreshProject()
            } catch { errorMessage = error.localizedDescription }
        }
    }

    private func restoreRecentWorkspaces() {
        let paths = UserDefaults.standard.stringArray(forKey: "recentWorkspacePaths") ?? []
        recentWorkspaces = paths.map(URL.init(fileURLWithPath:)).filter {
            FileManager.default.fileExists(atPath: $0.path)
        }
        if let first = recentWorkspaces.first { openWorkspace(first) }
    }

    private func persistRecentWorkspaces() {
        UserDefaults.standard.set(recentWorkspaces.map(\.path), forKey: "recentWorkspacePaths")
    }
}
