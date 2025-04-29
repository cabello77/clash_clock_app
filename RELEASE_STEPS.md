# Release Steps for Clash Clock App v2.0.1

Follow these steps to release the updated version to Google Play Console:

## 1. Build the Release APK/App Bundle

### Option A: Using the Build Script (Recommended)

We've created a build script that automatically tries different build strategies to help avoid common issues:

```bash
# Make sure the script is executable
chmod +x build_release.sh

# Run the build script
./build_release.sh
```

The script will:
1. Clean the project
2. Get dependencies
3. Try to use Java 11 if available (recommended for Flutter builds)
4. Try multiple build strategies automatically

### Option B: Manual Build

If you prefer to build manually:

```bash
# Clean the build
flutter clean

# Get dependencies
flutter pub get

# Try building with tree-shake icons disabled
flutter build appbundle --release --no-tree-shake-icons

# If that fails, try the split-per-abi approach
flutter build appbundle --release --split-per-abi
```

The app bundle will be created at:
`build/app/outputs/bundle/release/app-release.aab`

## 2. Google Play Console Upload

1. Sign in to your Google Play Console account
2. Navigate to your Clash Clock app
3. Go to "Production" section (or choose the appropriate release track)
4. Click "Create new release"
5. Upload the app bundle from `build/app/outputs/bundle/release/app-release.aab`
6. Add release notes detailing the bug fix:
   - Fixed an issue where deck wins and losses weren't properly updating after matches
   - Improved deck stats tracking
7. Review the release and submit it for review

### Version Code Management

**Important**: Each upload to Google Play Console requires a unique and incrementing version code. The current version is set to `2.0.1+17`. If you encounter a version code conflict:

1. Update the version code in `pubspec.yaml`:
   ```yaml
   version: 2.0.1+18  # Increment the number after the + sign
   ```
2. Update the CHANGELOG.md file to match
3. Rebuild the app bundle

## 3. Release Notes

Make sure to include the following in your release notes:

```
Version 2.0.1
- Fixed an issue where deck wins and losses weren't properly updating after matches
- Improved deck stats tracking
```

## 4. Testing

Before submitting the final release, consider testing the app bundle on a test device:

```bash
# Build app bundle for testing
flutter build appbundle --debug

# Or build APK for direct testing
flutter build apk --debug
flutter install
```

## 5. Troubleshooting Build Issues

### Java Compatibility Issues

If you encounter Java-related errors:

1. **Use Java 11**: Flutter works best with Java 11
   ```bash
   # On macOS, check available Java versions
   /usr/libexec/java_home -V
   
   # Switch to Java 11
   export JAVA_HOME=$(/usr/libexec/java_home -v 11)
   ```

2. **JVM Options in gradle.properties**: Make sure your JVM options are compatible with your Java version
   - For Java 8+: Use `-XX:MaxMetaspaceSize=512m` instead of `-XX:MaxPermSize=512m`

### Out of Memory Error (Exit Code -9)

If you encounter an "AOT snapshotter exited with code -9" error during build:

1. **Increase Flutter Memory Allocation**: 
   ```bash
   export FLUTTER_MEMORY=4G
   ```

2. **Try Split ABIs** (build separate bundles for each architecture):
   ```bash
   flutter build appbundle --release --split-per-abi
   ```

3. **Reduce Resources**:
   - Try building with fewer resources or a smaller app icon
   - Use `--no-tree-shake-icons` flag if tree-shaking is causing issues:
     ```bash
     flutter build appbundle --release --no-tree-shake-icons
     ```

4. **Free Up System Resources**:
   - Close all unnecessary applications
   - Restart your computer before building
   - Consider adding more RAM to your development machine 