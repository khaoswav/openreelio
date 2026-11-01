# BEYOND-MOTİON Native macOS

The macOS-only SwiftUI frontend is being migrated in parallel with the existing Tauri application. The existing Rust core remains the editing source of truth.

## Build and run

From the repository root:

```bash
chmod +x scripts/build-native-macos.sh
./scripts/build-native-macos.sh
```

Then run the executable printed by the script. The script builds the existing `openreelio-cli` against `openreelio-core` and the SwiftUI application. The SwiftUI app locates the CLI beside its executable or through `BEYOND_MOTION_CLI`.

You can also open `native-macos/Package.swift` in Xcode. For a working project/media bridge, build the Rust CLI first and set the `BEYOND_MOTION_CLI` environment variable in the scheme.

## Implemented native slice

- SwiftUI macOS app and native workspace flow.
- Native project creation through the existing Rust CLI/core.
- Project open and refresh through Rust.
- Media import into the real project asset store.
- Timeline tracks and clips read from the Rust project model.
- Insert selected media onto the first video track using the real timeline command.
- AVKit source preview and native editor layout.

## Migration boundary

This is an incremental port, not a claim of full feature parity. Effects, trim/move/split editing controls, AI workflows, rendering/export, preferences and remaining Tauri command coverage are still to be migrated. Do not remove the current Tauri/React app until those workflows are implemented and verified in SwiftUI.

The CLI is a headless frontend over `openreelio-core`; it avoids duplicating editing rules in Swift. The native bridge invokes it as a local process and exchanges JSON, keeping media processing and project mutation in Rust.
