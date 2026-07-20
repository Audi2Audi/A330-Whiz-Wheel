#!/bin/bash
# A330 Whiz Wheel - one-shot APK build (run on the Minisforum box)
# Prereqs: node 18+, JDK 17, Android SDK (ANDROID_HOME set, platform 34 + build-tools)
set -e
cd "$(dirname "$0")"
echo "==> Installing Capacitor..."
npm install --no-audit --no-fund
echo "==> Copying web app into www/..."
rm -rf www && mkdir www && cp ../index.html www/
if [ ! -d android ]; then
  echo "==> Creating Android project..."
  npx cap add android
fi
echo "==> Syncing..."
npx cap sync android
echo "==> Building debug APK (clean build)..."
cd android && ./gradlew --no-daemon clean assembleDebug
echo ""
echo "DONE: $(pwd)/app/build/outputs/apk/debug/app-debug.apk"
echo "Install: adb install ... or copy the APK to the phone and open it."
