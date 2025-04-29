#!/bin/bash

# Exit on error
set -e

echo "===== Clash Clock App Release Builder ====="
echo "This script will help build your app for release"

# Check Java version first
echo "Checking Java version..."
java_version=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | sed '/^1\./s///' | cut -d'.' -f1)
echo "Detected Java version: $java_version"

# Clean the project
echo "Cleaning the project..."
flutter clean

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Try to find Java 11 installation on macOS
if [ "$(uname)" == "Darwin" ]; then
  echo "macOS detected, checking for Java 11..."
  if /usr/libexec/java_home -v 11 &> /dev/null; then
    JAVA_11_HOME=$(/usr/libexec/java_home -v 11)
    echo "Java 11 found at: $JAVA_11_HOME"
    echo "Temporarily switching to Java 11 for build..."
    export JAVA_HOME="$JAVA_11_HOME"
  else
    echo "Java 11 not found. Using current Java version."
    echo "If build fails, consider installing Java 11."
  fi
fi

# Try different build strategies
echo "Building release app bundle..."

# Strategy 1: Regular build with tree shake icons disabled
echo "Strategy 1: Building with tree shake icons disabled..."
if flutter build appbundle --release --no-tree-shake-icons; then
  echo "Build successful!"
  exit 0
fi

echo "First strategy failed, trying alternative build method..."

# Strategy 2: Split per ABI
echo "Strategy 2: Building with split-per-abi..."
if flutter build appbundle --release --split-per-abi; then
  echo "Build successful!"
  exit 0
fi

echo "Second strategy failed, trying final strategy..."

# Strategy 3: Direct APK build
echo "Strategy 3: Building APK instead of app bundle..."
if flutter build apk --release --split-per-abi; then
  echo "APK build successful! You may need to upload individual APKs instead of a bundle."
  echo "APKs located in build/app/outputs/flutter-apk/"
  exit 0
fi

echo "All build strategies failed. Please check your environment and try again."
echo "You might need to check the Flutter doctor output for issues:"
flutter doctor -v

exit 1 