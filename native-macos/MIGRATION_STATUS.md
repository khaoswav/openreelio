# Native macOS migration status

Base: existing BEYOND-MOTİON Tauri + React + Rust application.

## Native foundation and Rust connection

- [x] SwiftUI macOS app entry point and native window.
- [x] Workspace selection and recent workspace list.
- [x] Native workspace dashboard and project creation.
- [x] Existing project discovery and opening from the workspace's Projects folder.
- [x] Rust CLI bridge using the repository's existing `openreelio-core`.
- [x] Import media into the actual Rust project asset store.
- [x] Read project assets, tracks and clips from Rust JSON responses.
- [x] Insert selected media into the first video track using the real timeline command.
- [x] Undo and redo through the Rust timeline command surface.
- [x] Native clip selection with a visible selected state.
- [x] Playhead position control with seconds display.
- [x] Split selected clips at the playhead through the Rust timeline command.
- [x] Remove selected clips through the Rust timeline command.
- [x] Clip context actions and keyboard shortcuts for split/delete.
- [x] Restore the SwiftUI-to-Rust CLI process bridge and typed JSON response models.
- [x] Drag clips horizontally to move them through the Rust timeline command.
- [x] Trim clip start/end handles through the Rust timeline trim command.
- [x] Extend the CLI trim command with an undoable timeline-in adjustment for left-edge trims.
- [x] Add a Rust CLI integration test for left-edge trim positioning.
- [x] Snap moved clips to nearby clip boundaries.
- [x] Native AVKit source preview and editor shell.
- [x] Build script for the SwiftUI app plus the headless Rust CLI.

## Remaining migration work

- [ ] Native track creation/removal, vertical clip movement between tracks and configurable snapping.
- [ ] Rendered timeline thumbnails and waveform data.
- [ ] Real timeline playback/composition preview (AVKit currently previews the selected source file).
- [ ] Effects, titles, audio controls and inspector editing.
- [ ] AI agent workflows, providers, conversation and project intelligence.
- [ ] Render/export pipeline, progress, cancellation and presets.
- [ ] Preferences, keyboard shortcut map, accessibility and localization.
- [ ] Native app bundle, signing, packaging and regression tests.
- [ ] Feature parity with the existing Tauri app.

## Migration rule

Do not delete the React/Tauri implementation until each equivalent SwiftUI workflow is connected to the shared Rust core and verified. The SwiftUI frontend must not reimplement project mutation or media processing rules in Swift.

