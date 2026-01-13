#!/bin/bash

# Stop the script if any command fails
set -e

APP_NAME="WindMan"

# 1. Kill old instances
# We filter to make sure we don't try to kill the system WindowManager
echo "💀 Killing old instances..."
pkill -9 -f ".build/debug/$APP_NAME" 2>/dev/null || true

# 2. Build the project
echo "🔨 Building $APP_NAME..."
swift build

# 3. Sign the binary (Ad-Hoc) to grant permissions
echo "✍️  Signing binary..."
codesign -s - --force .build/debug/$APP_NAME

# 4. Launch it in the background
echo "🚀 Launching..."
open .build/debug/$APP_NAME

echo "✅ Done! App is running in the menu bar."