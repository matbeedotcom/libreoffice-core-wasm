#!/bin/bash
#
# Generate WASM build fixes patch
# This script creates a clean patch from the base LibreOffice commit to the latest WASM changes
#

set -e

# Base commit (upstream LibreOffice before WASM changes)
BASE_COMMIT="d1c9e0e4e1ddeb24fe8f93e56860b3765043f8b1"

# Target commit (latest WASM changes) - update this as needed
TARGET_COMMIT="${1:-HEAD}"

# Output file
OUTPUT_FILE="wasm-build-fixes.patch"

# Files to exclude from the patch
EXCLUSIONS=(
    ':!*.bak'
    ':!*.orig'
    ':!config_build.mk'
    ':!config_host.mk'
    ':!config_host_lang.mk'
    ':!configure'
)

# Uncomment these to also exclude the autogen config files:
# EXCLUSIONS+=(':!.gitignore')
# EXCLUSIONS+=(':!autogen.input')
# EXCLUSIONS+=(':!autogen.input.writer-only')

echo "=== Generating WASM Build Patch ==="
echo "Base commit:   $BASE_COMMIT"
echo "Target commit: $TARGET_COMMIT"
echo "Output file:   $OUTPUT_FILE"
echo ""

# Generate the patch
git diff "$BASE_COMMIT".."$TARGET_COMMIT" -- . "${EXCLUSIONS[@]}" > "$OUTPUT_FILE"

# Show results
echo "=== Commits included ==="
git log --oneline "$BASE_COMMIT".."$TARGET_COMMIT"
echo ""

FILE_COUNT=$(grep -c "^diff --git" "$OUTPUT_FILE" || echo "0")
FILE_SIZE=$(ls -lh "$OUTPUT_FILE" | awk '{print $5}')

echo "=== Patch Summary ==="
echo "Files: $FILE_COUNT"
echo "Size:  $FILE_SIZE"
echo ""

echo "=== Files in patch ==="
grep "^diff --git" "$OUTPUT_FILE" | sed 's/diff --git a\///' | sed 's/ b\/.*//'
echo ""

echo "Done! Patch saved to: $OUTPUT_FILE"

