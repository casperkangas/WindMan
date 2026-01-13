#!/bin/bash

# Stop the script if any command fails
set -e

# 1. Kill the existing instance if it's running
# We use '|| true' so the script doesn't crash if the app isn't currently running
killall WindowManager 2>/dev/null || true

# 2. Build the project
echo "🔨 Building WindowManager..."
swift build

# 3. Sign the binary (Ad-Hoc) to grant permissions
echo "✍️  Signing binary..."
codesign -s - --force .build/debug/WindowManager

# 4. Launch it in the background
echo "🚀 Launching..."
open .build/debug/WindowManager

echo "✅ Done! App is running in the menu bar."