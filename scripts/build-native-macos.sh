#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "Building shared Rust editing engine (CLI bridge)…"
cargo build --release --manifest-path crates/openreelio-cli/Cargo.toml --bin openreelio-cli

echo "Building native SwiftUI application…"
swift build --package-path native-macos --configuration release

APP_BIN="$ROOT/native-macos/.build/release"
cp "$ROOT/target/release/openreelio-cli" "$APP_BIN/openreelio-cli"
echo "Native app: $APP_BIN/BEYOND-MOTION"
echo "Rust bridge: $APP_BIN/openreelio-cli"
echo "Run: BEYOND_MOTION_CLI=\"$APP_BIN/openreelio-cli\" \"$APP_BIN/BEYOND-MOTION\""
