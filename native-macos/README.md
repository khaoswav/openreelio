# BEYOND-MOTİON Native macOS

The native macOS editor is a SwiftUI frontend over the repository's existing Rust editing engine. The Tauri/React application remains available during the migration.

## Open in Xcode

1. Open Xcode.
2. Choose **File → Open…** and select this directory's `Package.swift`.
3. Select the **BEYOND-MOTION** executable scheme.
4. Choose **My Mac** and Run.

## Build and run the complete native slice

From the repository root:

```bash
chmod +x scripts/build-native-macos.sh
./scripts/build-native-macos.sh
```

The script builds `openreelio-cli` and the SwiftUI executable, then places the CLI beside the app executable. Run the command printed at the end of the script.

## Connected native workflows

- Workspace selection, recent workspaces, project discovery and project creation.
- Rust-backed project open, media import and asset/track/clip inspection.
- Native media browser, source preview, inspector and timeline shell.
- Insert media, select clips, move clips, split, remove, trim, undo and redo.
- Clip dragging snaps to the nearest nearby clip boundary.
- Left and right trim handles call the Rust timeline trim command. Left-edge trims also update timeline-in so the retained media stays aligned.
- The Rust CLI bridge is implemented in `RustCLIClient.swift` with typed response models.

## Current limitations

- The preview plays the selected source file, not the composited timeline.
- Vertical movement between tracks and native track creation/removal are not yet exposed in the SwiftUI timeline.
- Snap threshold is currently fixed; configurable snapping and frame-accurate zoom are still pending.
- Timeline thumbnails/waveforms, effects, titles, AI workflows, export, app signing and full feature parity remain in progress.

## Migration rule

The Rust core remains the source of truth for project state and media operations. Do not remove the React/Tauri implementation until equivalent native workflows are connected to the shared Rust core and verified.
