# iOS Build Troubleshooting Guide

This guide covers common issues when building and deploying the app to physical iOS devices.

## Table of Contents
- [Wireless Testing Setup](#wireless-testing-setup)
- [Common Build Errors](#common-build-errors)
- [Code Signing Issues](#code-signing-issues)

---

## Wireless Testing Setup

### Prerequisites
- Mac and iOS device on the same Wi-Fi network
- Xcode installed with iOS support files
- Apple Developer account configured

### Initial Setup (One-Time)

1. **Connect device via USB** (first time only)
2. Open Xcode → **Window → Devices and Simulators** (`⇧⌘2`)
3. Select your device from the left sidebar
4. Check **"Connect via network"**
5. Wait for network icon (🌐) to appear
6. Disconnect USB cable

### Building for Device

```bash
# Build web assets
npm run build

# Sync with iOS
npm run ios
```

In Xcode:
1. Select your device (with 🌐 icon) as build destination
2. Set your **Team** in Signing & Capabilities
3. Click Run (▶️)

---

## Common Build Errors

### Error: `iOS 26.1 is not installed`

**Cause:** Xcode doesn't have support files for your iOS version.

**Fix:**
- Click **"Get"** button in the device selector dropdown to download support files
- OR lower deployment target: Target → General → Minimum Deployments → iOS 17.0

---

### Error: `Command PhaseScriptExecution failed with a nonzero exit code`

**Cause:** Usually a CocoaPods or code signing issue.

**Fix:**
```bash
cd ios/App
pod install --repo-update
cd ../..
rm -rf ~/Library/Developer/Xcode/DerivedData
npm run build && npx cap sync ios
```

Then in Xcode: `⇧⌘K` (Clean) → `⌘B` (Build)

---

## Code Signing Issues

### Error: `errSecInternalComponent`

**Cause:** Keychain access was denied for the `codesign` tool, and macOS cached that denial.

**Symptoms:**
- Build fails during "Embed Pods Frameworks" phase
- Error message: `errSecInternalComponent`
- No keychain popup appears

**Fix:**

1. **Delete the corrupted certificate:**
```bash
security delete-certificate -c "Apple Development: <your-email>" ~/Library/Keychains/login.keychain-db
```

2. **Clear provisioning profiles:**
```bash
rm -rf ~/Library/MobileDevice/Provisioning\ Profiles/*
```

3. **Clear derived data:**
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
```

4. **Re-download certificate in Xcode:**
   - Xcode → Settings → Accounts
   - Select your Apple ID
   - Click **Manage Certificates**
   - Click **+** → **Apple Development**
   - Close window

5. **Rebuild the project:**
   - Clean: `⇧⌘K`
   - Build: `⌘B`

6. **When keychain popup appears:**
   - ✅ **ALWAYS click "Always Allow"** (even if it asks multiple times)
   - ❌ **NEVER click "Deny"** - this causes the error

---

### Keychain Password Issues

**Problem:** Keychain password doesn't match your Mac login password.

**Fix:**

1. Open **Keychain Access** app
2. Menu: **Edit → Change Password for Keychain "login"**
3. Try leaving "Current Password" **blank** or enter old password
4. Set new password to your **current Mac login password**

---

### Certificate Access Control

**Problem:** Certificate has wrong access permissions.

**Fix:**

1. Open **Keychain Access** app
2. Find **"Apple Development: <your-email>"** certificate
3. Double-click → **Access Control** tab
4. Select **"Allow all applications to access this item"**
5. Click **Save Changes**
6. Do the same for the **private key** (expand certificate with triangle icon)

---

## Nuclear Options

### Reset iOS Project

If all else fails, recreate the iOS project from scratch:

```bash
# Delete iOS project
rm -rf ios
rm -rf ~/Library/Developer/Xcode/DerivedData/App-*

# Recreate fresh
npx cap add ios
npx cap sync ios
npx cap open ios
```

Then configure signing in Xcode and build.

---

### Reinstall Xcode Command Line Tools

```bash
sudo rm -rf /Library/Developer/CommandLineTools
xcode-select --install
```

---

## Best Practices

### ✅ DO:
- Always click "Always Allow" for keychain access
- Keep Xcode and iOS updated
- Use automatic code signing when possible
- Clean build folder regularly (`⇧⌘K`)

### ❌ DON'T:
- Click "Deny" on keychain popups
- Manually modify Pods files (they get regenerated)
- Commit `ios/` folder to git (it's in `.gitignore`)
- Use multiple Apple IDs in the same Xcode installation

---

## Quick Reference Commands

```bash
# Clean everything
rm -rf ios
rm -rf ~/Library/Developer/Xcode/DerivedData
npm run build && npx cap add ios

# Sync changes
npm run build && npx cap sync ios

# Open in Xcode
npx cap open ios

# Update pods
cd ios/App && pod install && cd ../..

# Check certificates
security find-identity -v -p codesigning

# Unlock keychain
security unlock-keychain ~/Library/Keychains/login.keychain-db
```

---

## Getting Help

If you're still stuck:
1. Check the full error message in Xcode's Report Navigator (`⌘9`)
2. Search for the specific error on [Stack Overflow](https://stackoverflow.com)
3. Check [Capacitor iOS Documentation](https://capacitorjs.com/docs/ios)
4. Verify your Apple Developer account is active

---

**Last Updated:** November 23, 2025
