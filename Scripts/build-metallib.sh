#!/bin/bash
# Regenerates Framework/MetalImage/default.metallib from all .metal sources.
#
# SwiftPM cannot compile Metal shaders (it ships them as raw resources), so the
# package loads this prebuilt library from MetalImage_MetalImage.bundle via
# MetalDevice's newDefaultLibraryWithBundle: lookup. Re-run this script whenever
# a .metal file changes and commit the updated metallib.
#
# Requires the Metal toolchain: xcodebuild -downloadComponent MetalToolchain

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SHADER_DIR="$REPO_ROOT/Framework/MetalImage"
OUTPUT="$SHADER_DIR/default.metallib"

# AIR is platform-independent IR; linking against the iOS SDK covers the
# package's only supported platform.
xcrun -sdk iphoneos metal -gline-tables-only "$SHADER_DIR"/*.metal -o "$OUTPUT"

echo "Wrote $OUTPUT ($(du -h "$OUTPUT" | cut -f1))"
