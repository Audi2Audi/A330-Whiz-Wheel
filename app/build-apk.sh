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
echo "==> Installing Whiz Wheel app icon..."
for d in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
  cp icon-assets/mipmap-$d/*.png android/app/src/main/res/mipmap-$d/
done
mkdir -p android/app/src/main/res/mipmap-anydpi-v26
cp icon-assets/mipmap-anydpi-v26/*.xml android/app/src/main/res/mipmap-anydpi-v26/
cp icon-assets/values/ic_launcher_background.xml android/app/src/main/res/values/ic_launcher_background.xml
echo "==> Syncing..."
npx cap sync android
echo "==> Building debug APK (clean build)..."
cd android && ./gradlew --no-daemon clean assembleDebug
echo ""
echo "DONE: $(pwd)/app/build/outputs/apk/debug/app-debug.apk"
echo "Install: adb install ... or copy the APK to the phone and open it."
