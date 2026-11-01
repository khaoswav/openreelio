# BEYOND-MOTİON Native macOS

This directory starts the macOS-only SwiftUI migration while preserving the existing Rust and Tauri application.

## Open in Xcode

1. Open Xcode.
2. Choose **File → Open…** and select this `Package.swift`.
3. Select the **BEYOND-MOTION** executable scheme.
4. Choose **My Mac** and Run.

Or build from Terminal:

```bash
cd native-macos
swift build
```

## Current migration slice

- Native SwiftUI app entry point and macOS window.
- Native workspace chooser with recent workspace paths.
- Native editor shell with media browser, viewer, inspector and timeline layout.
- Local media import and AVKit preview for supported video/audio files.
- BEYOND-MOTİON brand palette and a material-based macOS visual system.

## Important scope boundary

This is the first native UI foundation, not a claim that the full editor has already been ported. The existing Tauri/React application and Rust code remain intact. Editing operations, project persistence, AI workflows, export, effects and timeline editing are not yet connected to this SwiftUI shell.

## Rust integration plan

The current Rust implementation remains the source of truth. The next migration step is to define a stable native boundary around the existing Rust core and progressively replace Tauri IPC calls with that boundary. Before wiring it, audit the existing Tauri command surface and the `crates/openreelio-cli` interfaces. Prefer a typed local bridge with explicit request/response models; do not duplicate media-processing or AI logic in Swift.

The old Tauri application remains available throughout the migration so existing workflows are not lost while each native screen reaches feature parity.
