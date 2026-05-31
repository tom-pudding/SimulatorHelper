# Simulator Helper Architecture

## 1. Chosen Approach

### Selected approach
Use Foundation `Process` to invoke `xcrun simctl`, with capability detection driven by the installed toolchain.

### Why this is the right choice
- public Apple tooling
- matches the product requirement exactly
- no third-party dependencies
- supports SwiftUI + MVVM cleanly
- resilient to Xcode drift when paired with runtime capability detection

### Rejected approaches

#### Private CoreSimulator frameworks
Rejected because:
- private API risk
- weak forward compatibility
- unnecessary for the MVP

#### Wrapper shell scripts
Rejected because:
- adds packaging complexity
- harder to test and debug than direct Swift process execution
- offers no architectural advantage over `Process`

## 2. MVP Architecture Summary

```text
SwiftUI App
  -> AppViewModel
    -> SimulatorInventoryService
    -> StatusBarCapabilitiesService
    -> StatusBarCommandService
    -> ScreenshotService
    -> EnvironmentService
    -> AppSettingsStore
      -> ProcessRunner
        -> /usr/bin/xcrun simctl
```

## 3. Window and View Structure

### Single-window structure
- `ContentView`
  - `SimulatorSidebarView`
  - `EnvironmentBannerView`
  - `StatusBarFormView`
  - `ScreenshotSectionView`
  - `StatusMessageView`

### ViewModel structure
- `AppViewModel`
  - owns top-level app state, loading, errors, and coordination
- `SimulatorListViewModel`
  - owns booted simulator data and single selection
- `StatusBarFormViewModel`
  - owns editable MVP status bar form values and validation
- `ScreenshotViewModel`
  - owns destination folder state and screenshot capture action

## 4. MVP Modules

### `ProcessRunner`
Responsibilities:
- run external commands
- capture stdout/stderr
- return termination status
- standardize errors and timeouts

### `EnvironmentService`
Responsibilities:
- verify `xcrun` is available
- determine active Xcode version
- surface readiness state to the UI

### `SimulatorInventoryService`
Responsibilities:
- run `xcrun simctl list devices --json`
- decode the result
- filter to booted iOS and iPadOS simulators only
- sort into a stable display order

### `StatusBarCapabilitiesService`
Responsibilities:
- run `xcrun simctl help status_bar`
- parse the installed toolchain’s supported flags and values
- return a capability model

### `StatusBarCommandService`
Responsibilities:
- validate the form
- map form values to `simctl status_bar override`
- run `clear` when requested
- return success/failure details

### `ScreenshotService`
Responsibilities:
- validate the selected destination folder
- generate the output filename
- run `xcrun simctl io <device> screenshot <path>`

### `AppSettingsStore`
Responsibilities:
- persist the selected screenshot folder
- restore it on next launch

MVP note:
- persist only the folder
- do not persist the full status bar form until later

## 5. Data Model Design

### `SimulatorDescriptor`
Fields:
- `udid`
- `name`
- `runtimeIdentifier`
- `runtimeName`
- `deviceTypeIdentifier`
- `productFamily`
- `state`
- `lastBootedAt`

### `SimulatorSelectionState`
Fields:
- `selectedSimulatorIDs: [String]`

Design note:
- the data shape stays future-ready for multi-selection
- the MVP UI enforces zero or one selected simulator

### `StatusBarCapabilities`
Fields:
- `supportedFlags`
- `supportedDataNetworks`
- `supportedWiFiModes`
- `supportedCellularModes`
- `supportedBatteryStates`
- `wifiBarsRange`
- `cellularBarsRange`
- `batteryLevelRange`

### `MVPStatusBarConfiguration`
Fields:
- `timeString`
- `dataNetwork`
- `wifiMode`
- `wifiBars`
- `cellularMode`
- `cellularBars`
- `batteryState`
- `batteryLevel`

Design note:
- `operatorName` is intentionally omitted from the MVP form model
- it belongs in the broader configuration model for version 1.1

### `ScreenshotDestination`
Fields:
- `folderURL`
- `displayPath`

### `EnvironmentStatus`
Fields:
- `xcodeVersion`
- `xcodeBuild`
- `developerDirectory`
- `simctlAvailable`
- `statusBarSupportAvailable`
- `warnings`

## 6. Capability Detection Strategy

### Why detection matters
Apple changes simulator and Xcode behavior over time, and the exact `status_bar` command surface is not fully documented per point release.

### Strategy
At app launch:

1. run `xcrun simctl help status_bar`
2. parse supported flags and enumerated values
3. cache the result in memory for the current launch
4. allow the UI to expose only the intersection of:
   - MVP-supported controls
   - toolchain-supported controls

### Result
- the MVP stays intentionally small
- the app does not assume unsupported flags exist
- later versions can unlock more options safely

## 7. Command Mapping

### Simulator list
Command:
- `xcrun simctl list devices --json`

### Apply status bar settings
Base command:
- `xcrun simctl status_bar <udid> override ...`

### Clear status bar settings
Command:
- `xcrun simctl status_bar <udid> clear`

### Capture screenshot
Command:
- `xcrun simctl io <udid> screenshot <path>`

## 8. UI State Rules

### No booted simulator
- empty sidebar state
- form disabled
- screenshot action disabled
- message tells the user to boot a simulator in Simulator.app

### Environment invalid
- banner shown at top of content area
- actions disabled if `xcrun` or `simctl` is unavailable

### Command running
- disable action buttons
- show progress text
- prevent double-submission

### Command success
- show short confirmation
- keep the user in the main workflow

### Command failure
- show a human-readable summary first
- raw stderr can be attached internally for debugging, but not as the primary UX

## 9. What Is Explicitly Deferred

Deferred beyond MVP:
- carrier name editing
- advanced network variants
- open save folder action
- auto-refresh polling
- status form persistence
- preset storage
- batch capture

## 10. Technical Feasibility

### Feasible in MVP
- booted simulator detection
- single-simulator targeting
- status bar override application
- status bar clearing
- screenshot capture to a selected folder

### Constraints
- shutdown devices cannot accept `status_bar` commands
- screenshots and overrides only make sense for booted devices
- visual status bar appearance differs by device family and current screen
- some screens hide the status bar entirely

### Distribution note
Because distribution is through GitHub Releases, the architecture does not need to optimize for Mac App Store sandbox constraints in MVP.

The recommended release quality bar is still:
- sign
- notarize
- publish
