import Foundation

enum RustCLIError: LocalizedError {
    case executableNotFound
    case launchFailed(String)
    case commandFailed(status: Int32, message: String)
    case invalidJSON(String)

    var errorDescription: String? {
        switch self {
        case .executableNotFound:
            return "The Rust editing engine could not be found. Build it with scripts/build-native-macos.sh."
        case .launchFailed(let message):
            return "Could not start the Rust editing engine: \(message)"
        case .commandFailed(let status, let message):
            return "Rust command failed (\(status)): \(message)"
        case .invalidJSON(let message):
            return "The Rust engine returned an unreadable response: \(message)"
        }
    }
}

/// Runs the repository's existing Rust CLI. SwiftUI owns presentation only;
/// project mutations and media rules remain in openreelio-core.
struct RustCLIClient {
    func runJSON<T: Decodable>(_ arguments: [String]) async throws -> T {
        try await Task.detached(priority: .userInitiated) {
            let data = try Self.execute(arguments)
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                let preview = String(data: data.prefix(1200), encoding: .utf8) ?? "<non-UTF8 response>"
                throw RustCLIError.invalidJSON("\(error.localizedDescription). Response: \(preview)")
            }
        }.value
    }

    private static func execute(_ arguments: [String]) throws -> Data {
        let executable = try locateExecutable()
        let process = Process()
        let output = Pipe()
        process.executableURL = executable
        process.arguments = ["--quiet"] + arguments
        process.standardOutput = output
        process.standardError = FileHandle.standardError

        do {
            try process.run()
        } catch {
            throw RustCLIError.launchFailed(error.localizedDescription)
        }

        let data = output.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            let message = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
                ?? "No error details were returned."
            throw RustCLIError.commandFailed(status: process.terminationStatus, message: message)
        }
        return data
    }

    private static func locateExecutable() throws -> URL {
        let fileManager = FileManager.default
        var candidates: [URL] = []

        if let configured = ProcessInfo.processInfo.environment["BEYOND_MOTION_CLI"], !configured.isEmpty {
            candidates.append(URL(fileURLWithPath: configured))
        }

        let bundle = Bundle.main.bundleURL
        candidates.append(bundle.appendingPathComponent("Contents/Helpers/openreelio-cli"))
        candidates.append(bundle.appendingPathComponent("Contents/MacOS/openreelio-cli"))

        let executableFolder = URL(fileURLWithPath: CommandLine.arguments[0])
            .standardizedFileURL.deletingLastPathComponent()
        candidates.append(executableFolder.appendingPathComponent("openreelio-cli"))
        candidates.append(executableFolder.appendingPathComponent("../Resources/openreelio-cli").standardizedFileURL)

        if let currentDirectory = ProcessInfo.processInfo.environment["PWD"] {
            candidates.append(URL(fileURLWithPath: currentDirectory)
                .appendingPathComponent("target/release/openreelio-cli"))
        }

        if let found = candidates.first(where: {
            fileManager.isExecutableFile(atPath: $0.path)
        }) {
            return found
        }
        throw RustCLIError.executableNotFound
    }
}

struct CLIProjectCreated: Decodable {
    let status: String
    let name: String
    let path: String
}

struct CLIStatusResponse: Decodable {
    let status: String
    let opId: String?
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
    let muted: Bool?
    let locked: Bool?
}

struct CLIClipList: Decodable {
    let sequenceId: String
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
