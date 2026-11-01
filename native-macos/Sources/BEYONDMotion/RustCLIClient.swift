import Foundation

enum NativeBridgeError: LocalizedError {
    case executableMissing
    case commandFailed(String)

    var errorDescription: String? {
        switch self {
        case .executableMissing:
            return "Rust editing engine not found. Build it with scripts/build-native-macos.sh."
        case .commandFailed(let message):
            return message
        }
    }
}

struct RustCLIClient {
    private func executableURL() -> URL? {
        if let override = ProcessInfo.processInfo.environment["BEYOND_MOTION_CLI"] {
            return URL(fileURLWithPath: override)
        }

        let candidates = [
            Bundle.main.bundleURL.appendingPathComponent("Contents/Helpers/openreelio-cli"),
            Bundle.main.bundleURL.appendingPathComponent("Contents/MacOS/openreelio-cli"),
            Bundle.main.executableURL?.deletingLastPathComponent().appendingPathComponent("openreelio-cli")
        ].compactMap { $0 }

        return candidates.first { FileManager.default.isExecutableFile(atPath: $0.path) }
    }

    func runJSON<T: Decodable>(_ arguments: [String], as type: T.Type = T.self) async throws -> T {
        guard let executable = executableURL() else { throw NativeBridgeError.executableMissing }

        let data = try await Task.detached(priority: .userInitiated) {
            let process = Process()
            let stdout = Pipe()
            let stderr = Pipe()
            process.executableURL = executable
            process.arguments = ["--quiet"] + arguments
            process.standardOutput = stdout
            process.standardError = stderr

            do {
                try process.run()
            } catch {
                throw NativeBridgeError.commandFailed("Could not start the Rust engine: \(error.localizedDescription)")
            }

            let output = stdout.fileHandleForReading.readDataToEndOfFile()
            let errorOutput = stderr.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()

            guard process.terminationStatus == 0 else {
                let message = String(data: errorOutput, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
                throw NativeBridgeError.commandFailed(message?.isEmpty == false ? message! : "Rust engine exited with code \(process.terminationStatus).")
            }
            return output
        }.value

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NativeBridgeError.commandFailed("Rust engine returned an unexpected response: \(error.localizedDescription)")
        }
    }
}

struct CLIProjectCreated: Decodable {
    let status: String
    let name: String
    let path: String
}

struct CLIAssetList: Decodable {
    let assets: [CLIAsset]
}

struct CLIAsset: Decodable, Identifiable {
    let id: String
    let name: String
    let kind: String
    let uri: String
    let durationSec: Double?
    let video: CLIVideoInfo?
    let audio: CLIAudioInfo?
}

struct CLIVideoInfo: Decodable {
    let width: Int?
    let height: Int?
    let fps: Double?
}

struct CLIAudioInfo: Decodable {
    let sampleRate: Int?
    let channels: Int?
}

struct CLITrackList: Decodable {
    let sequenceId: String
    let tracks: [CLITrack]
}

struct CLITrack: Decodable, Identifiable {
    let id: String
    let name: String
    let kind: String
    let clipCount: Int
    let muted: Bool
    let locked: Bool
}

struct CLIClipList: Decodable {
    let clips: [CLIClip]
}

struct CLIClip: Decodable, Identifiable {
    let id: String
    let trackId: String
    let assetId: String
    let timelineInSec: Double
    let durationSec: Double
    let sourceInSec: Double
    let sourceOutSec: Double
    let speed: Double
}
