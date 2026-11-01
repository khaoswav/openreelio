import AVKit
import SwiftUI
import UniformTypeIdentifiers

struct MediaAsset: Identifiable {
    let id = UUID()
    let url: URL

    var name: String { url.deletingPathExtension().lastPathComponent }
    var fileType: String { url.pathExtension.uppercased() }
}

@MainActor
final class AppState: ObservableObject {
    @Published var workspaceURL: URL?
    @Published var recentWorkspaces: [URL] = []
    @Published var mediaAssets: [MediaAsset] = []
    @Published var selectedAssetID: UUID?
    @Published var player: AVPlayer?
    @Published var isWorkspacePickerPresented = false
    @Published var isMediaPickerPresented = false

    private var activeWorkspaceURL: URL?
    private var scopedMediaURLs: Set<URL> = []

    var selectedAsset: MediaAsset? {
        mediaAssets.first { $0.id == selectedAssetID }
    }

    init() {
        restoreRecentWorkspaces()
    }

    func openWorkspace(_ url: URL) {
        if let activeWorkspaceURL {
            activeWorkspaceURL.stopAccessingSecurityScopedResource()
        }

        _ = url.startAccessingSecurityScopedResource()
        activeWorkspaceURL = url
        workspaceURL = url

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

    func importMedia(_ urls: [URL]) {
        let supported = urls.filter { url in
            let type = UTType(filenameExtension: url.pathExtension)
            return type?.conforms(to: .movie) == true
                || type?.conforms(to: .video) == true
                || type?.conforms(to: .audio) == true
        }

        for url in supported {
            _ = url.startAccessingSecurityScopedResource()
            scopedMediaURLs.insert(url)
            guard !mediaAssets.contains(where: { $0.url == url }) else { continue }
            mediaAssets.append(MediaAsset(url: url))
        }

        if selectedAssetID == nil, let first = mediaAssets.first {
            selectAsset(first)
        }
    }

    func selectAsset(_ asset: MediaAsset) {
        selectedAssetID = asset.id
        player?.pause()
        player = AVPlayer(url: asset.url)
    }

    private func restoreRecentWorkspaces() {
        let paths = UserDefaults.standard.stringArray(forKey: "recentWorkspacePaths") ?? []
        recentWorkspaces = paths.map(URL.init(fileURLWithPath:)).filter {
            FileManager.default.fileExists(atPath: $0.path)
        }
        if let first = recentWorkspaces.first {
            openWorkspace(first)
        }
    }

    private func persistRecentWorkspaces() {
        UserDefaults.standard.set(recentWorkspaces.map(\.path), forKey: "recentWorkspacePaths")
    }
}
