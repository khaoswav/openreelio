# Native macOS migration status

Base: existing BEYOND-MOTİON Tauri + React + Rust application.

## Phase 1 — Native shell foundation

- [x] SwiftUI application entry point.
- [x] macOS workspace selection and recent workspace list.
- [x] Native editor shell layout.
- [x] Media import and AVKit preview foundation.
- [x] Preserve existing Tauri and Rust source unchanged.

## Not yet migrated

- [ ] Rust core bridge and typed request/response contract.
- [ ] Existing project open/save and sequence model.
- [ ] Real timeline editing, trim, move, snapping and track operations.
- [ ] Effects, titles, audio tools and inspector bindings.
- [ ] AI agent workflows and provider settings.
- [ ] Render/export pipeline and progress reporting.
- [ ] Native preferences, keyboard shortcuts, accessibility and localization.
- [ ] Feature parity and regression tests.

## Migration rule

Do not delete the React/Tauri implementation until the equivalent SwiftUI screen is implemented, connected to the Rust core, and verified against the existing behavior.
