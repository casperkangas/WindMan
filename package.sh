#!/bin/bash

APP_NAME="WindowManager"
EXECUTABLE_NAME="WindowManager"
BUNDLE_ID="com.casperkangas.windowmanager"
VERSION="0.1.0"

# 1. Clean and Build Release
echo "🧼 Cleaning previous builds..."
rm -rf .build/release
rm -rf "$APP_NAME.app"
rm -rf "$APP_NAME.zip"

echo "🚀 Building Release version (Optimized)..."
swift build -c release --arch arm64 --arch x86_64

# 2. Create App Bundle Structure
echo "📦 Creating .app bundle..."
mkdir -p "$APP_NAME.app/Contents/MacOS"
mkdir -p "$APP_NAME.app/Contents/Resources"

# 3. Copy the binary
cp ".build/release/$EXECUTABLE_NAME" "$APP_NAME.app/Contents/MacOS/"

# 4. Create Info.plist (Crucial for a real app)
# This tells macOS it's an app, hides it from the Dock (LSUIElement), and sets your version.
cat <<EOF > "$APP_NAME.app/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$EXECUTABLE_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# 5. Sign the App Bundle
# We use ad-hoc signing (-) but deeper (deep) to sign frameworks if needed.
echo "✍️  Signing app bundle..."
codesign --force --deep --sign - "$APP_NAME.app"

# 6. Zip it for GitHub
echo "🤐 Zipping for release..."
zip -r "$APP_NAME.zip" "$APP_NAME.app"

echo "✅ Done! You can find '$APP_NAME.zip' in this folder."
echo "   Upload this zip file to your GitHub Release."