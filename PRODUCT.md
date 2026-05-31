# Simulator Helper

## 1. Product Definition

### Purpose
Simulator Helper is a native macOS utility for one narrow developer workflow:

1. choose a booted iPhone or iPad simulator
2. normalize the simulator status bar for screenshots
3. capture the screenshot to a predictable folder

### Problem
Today this workflow depends on remembering `xcrun simctl` commands. The original pain point was simple and real: waiting until `9:41 AM` because changing simulator time was not obvious without Terminal.

### Target user
- iOS developers who regularly create App Store screenshots
- Solo developers and small teams using Simulator heavily
- Developers who want a GUI instead of command-line snippets

### Product stance
This is a focused screenshot-preparation utility, not a general simulator manager.

## 2. Locked Decisions

These decisions are now final for design:

- Distribution: **GitHub Releases**
- Platform: **native macOS app**
- UI: **SwiftUI**
- Architecture: **MVVM**
- Dependencies: **no third-party dependencies**
- Simulator control: **use `xcrun simctl` internally**
- Minimum macOS version: **15.0+**
- Simulator discovery: **booted simulators only**
- Simulator lifecycle in MVP: **do not boot or shut down simulators**
- Status bar import in MVP: **do not import current simulator status bar settings**
- Screenshot folder strategy: default to `~/Desktop/Simulator Helper`, allow changing it, persist the chosen folder
- Screenshot naming strategy: `<device-name>_<yyyy-MM-dd_HH-mm-ss>.png`

## 3. Final MVP

### MVP goal
Solve the core screenshot workflow with the fewest moving parts.

### MVP features
- Detect booted iOS and iPadOS simulators
- Show the booted simulator list
- Allow selecting one simulator
- Manual refresh of the simulator list
- Show environment readiness:
  - `xcrun` available or not
  - active Xcode version
- Configure these status bar controls:
  - Time
  - Network type
    - `Wi-Fi`
    - `3G`
    - `4G`
    - `LTE`
    - `5G`
  - Wi-Fi mode
  - Wi-Fi signal strength
  - Cellular mode
  - Cellular signal strength
  - Battery level
  - Battery state
- Apply status bar overrides
- Clear status bar overrides
- Choose screenshot save folder
- Persist chosen save folder
- Capture screenshot with `simctl io screenshot`
- Show clear success/error feedback

### Removed from MVP as non-essential
- Carrier name editing
- Advanced data network variants:
  - `hide`
  - `lte-a`
  - `lte+`
  - `5g+`
  - `5g-uwb`
  - `5g-uc`
- Open save folder action
- Auto-refresh polling
- Persisting last-used status bar form values
- File-name preview UI
- Any simulator boot, shutdown, or creation controls
- Importing or reading back current override state into the form

### Why these cuts are correct
- The true MVP is about faster screenshot setup, not exhaustive simulator control.
- The smallest useful workflow is:
  - pick booted simulator
  - set time and common screenshot indicators
  - apply
  - capture
- Everything else is convenience, not necessity.

## 4. Version Roadmap

### MVP
- Booted simulator detection
- Single selection
- Curated status bar controls
- Apply and clear
- Folder selection and persistence
- Screenshot capture
- Environment banner and friendly errors

### Version 1.1
- Carrier name editing
- Advanced data network variants:
  - `hide`
  - `lte-a`
  - `lte+`
  - `5g+`
  - `5g-uwb`
  - `5g-uc`
- Open save folder
- Persist last-used status bar form values
- Optional auto-refresh of the booted simulator list
- Better post-capture confirmation details

### Version 1.2
- Presets
- Saved configuration profiles
- App Store Screenshot Mode
- Batch capture across multiple simulators
- Screenshot session management
- App Store Connect asset helper

## 5. Verified `status_bar` Support

### Current Apple release context
As of **May 31, 2026**, Apple’s support matrix lists **Xcode 26.5** as the current Xcode release family.

### Local toolchain used for direct verification
Direct command verification was run against the installed local toolchain on **May 31, 2026**:

- `Xcode 26.2`
- build `17C52`

### What is actually supported by the verified local simulator toolchain
`xcrun simctl help status_bar` currently supports these flags:

- `--time`
- `--dataNetwork`
- `--wifiMode`
- `--wifiBars`
- `--cellularMode`
- `--cellularBars`
- `--operatorName`
- `--batteryState`
- `--batteryLevel`

Supported `dataNetwork` values in the verified local toolchain:

- `hide`
- `wifi`
- `3g`
- `4g`
- `lte`
- `lte-a`
- `lte+`
- `5g`
- `5g+`
- `5g-uwb`
- `5g-uc`

Supported `wifiMode` values:

- `searching`
- `failed`
- `active`

Supported `cellularMode` values:

- `notSupported`
- `searching`
- `failed`
- `active`

Supported `batteryState` values:

- `charging`
- `charged`
- `discharging`

Numeric ranges:

- `wifiBars`: `0...3`
- `cellularBars`: `0...4`
- `batteryLevel`: `0...100`

### Important design interpretation
Apple’s public release notes do **not** publish a full `simctl status_bar` flag matrix for each Xcode point release, so exact `26.5` flag parity is **unknown** from public documentation alone.

Because of that, the app should:

1. treat the installed `xcrun simctl help status_bar` output as the runtime source of truth
2. expose only a curated subset in MVP
3. reserve the broader supported set for later versions

## 6. Confirmed Constraints

Verified on May 31, 2026:

- `simctl status_bar` fails on shutdown simulators
- `simctl io <device> screenshot <path>` works on booted simulators
- applying and clearing overrides worked locally on a booted iPhone simulator without relaunch
- visual results differ between iPhone and iPad layouts
- some screens hide the status bar entirely, so command success and visible change are not always identical

## 7. Final UI Wireframe

```text
+----------------------------------------------------------------------------------+
| Simulator Helper                                             Xcode 26.2 | Ready |
+---------------------------+------------------------------------------------------+
| Booted Simulators         | Environment                                          |
|                           | Active toolchain: Xcode 26.2 (17C52)                |
| [iPhone 17 Pro]           |                                                      |
| [iPad Pro 13-inch (M5)]   | Status Bar                                           |
|                           | Time             [ 9:41                       ]       |
| [Refresh]                 | Network Type     [ Wi-Fi v ]                        |
|                           | Wi-Fi Mode       [ Active v ]   Wi-Fi Bars   [ 3 ]  |
|                           | Cellular Mode    [ Active v ]   Cellular Bars [ 4 ] |
|                           | Battery State    [ Charged v ]  Battery      [100]  |
|                           |                                                      |
|                           | [Apply Settings]   [Clear Overrides]                |
|                           |                                                      |
|                           | Screenshot                                           |
|                           | Save Folder      [~/Desktop/Simulator Helper] [Change]|
|                           |                                                      |
|                           | [Capture Screenshot]                                 |
|                           |                                                      |
|                           | Status                                               |
|                           | Ready for screenshot capture.                        |
+---------------------------+------------------------------------------------------+
```

### MVP UX rules
- If no booted simulators exist, show an empty state and disable all actions.
- If the environment is invalid, show that banner before the form.
- Keep one clear primary action path: select simulator, apply, capture.

## 8. Release Recommendation

For GitHub Releases, the recommended shipping path is:

1. Developer ID sign the app
2. notarize it
3. distribute the `.app` or packaged archive on GitHub Releases

This is not part of MVP feature scope, but it is the recommended release quality bar.

## 9. Approval State

This design package is now in final pre-implementation form and waiting for approval.
