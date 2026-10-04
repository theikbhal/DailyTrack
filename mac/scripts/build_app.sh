#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

APP_NAME="DailyTrack"
BUNDLE_ID="com.ikbhal.dailytrack"
VERSION="1.0.0"
BUILD_ONLY=0
if [[ "${1:-}" == "--build-only" ]]; then BUILD_ONLY=1; fi

echo "==> building release binary"
swift build -c release
BIN="$(swift build -c release --show-bin-path)/$APP_NAME"

APP="build/$APP_NAME.app"
echo "==> assembling $APP"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

if [[ ! -f Resources/AppIcon.png ]]; then
  echo "==> generating icon source"
  swift scripts/make_icon.swift Resources/AppIcon.png
fi

cp "$BIN" "$APP/Contents/MacOS/$APP_NAME"
chmod +x "$APP/Contents/MacOS/$APP_NAME"
printf 'APPL????' > "$APP/Contents/PkgInfo"

ICONSET="$APP/Contents/Resources/AppIcon.iconset"
mkdir -p "$ICONSET"
for s in 16 32 128 256 512; do
  sips -z "$s" "$s" Resources/AppIcon.png --out "$ICONSET/icon_${s}x${s}.png" >/dev/null
  sips -z $((s * 2)) $((s * 2)) Resources/AppIcon.png --out "$ICONSET/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"
rm -rf "$ICONSET"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>$APP_NAME</string>
  <key>CFBundleDisplayName</key><string>$APP_NAME</string>
  <key>CFBundleExecutable</key><string>$APP_NAME</string>
  <key>CFBundleIdentifier</key><string>$BUNDLE_ID</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>$VERSION</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>LSMinimumSystemVersion</key><string>14.0</string>
  <key>NSHighResolutionCapable</key><true/>
  <key>NSPrincipalClass</key><string>NSApplication</string>
  <key>LSUIElement</key><false/>
</dict>
</plist>
PLIST

echo "==> codesigning (ad-hoc)"
codesign --force --deep --sign - "$APP" 2>/dev/null || echo "    (codesign skipped)"

if [[ "$BUILD_ONLY" == "0" ]]; then
  echo "==> installing to /Applications"
  rm -rf "/Applications/$APP_NAME.app"
  cp -R "$APP" "/Applications/"
  echo "==> creating desktop shortcut"
  ln -sfn "/Applications/$APP_NAME.app" "$HOME/Desktop/$APP_NAME"
  echo "==> registering in AppTracker"
  python3 scripts/register_apptracker.py
  echo "==> done. open /Applications/$APP_NAME.app"
else
  echo "==> build-only. open $APP"
fi
