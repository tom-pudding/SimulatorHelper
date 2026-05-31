# Simulator Helper

Simulator Helper is a native macOS SwiftUI utility for configuring iOS Simulator status bar settings and capturing screenshots without using Terminal.

## Current Status

MVP implementation is complete.

Implemented so far:
- macOS SwiftUI app scaffold
- MVVM-oriented source layout
- shared `ProcessRunner`
- `EnvironmentService` for Xcode and `simctl` readiness checks
- environment banner and toolchain details UI
- booted iPhone and iPad simulator discovery
- simulator sidebar with single selection
- manual simulator refresh
- status bar capability detection from the active `simctl`
- validated status bar form and apply/clear actions
- focused status bar controls for screenshot-safe overrides only:
  - time-only on iPhone
  - date-plus-time on iPad
  - battery level
- iPhone-aware UI that keeps `Date + Time` unavailable unless an iPad simulator is selected
- screenshot folder persistence with a default Desktop destination
- screenshot filename generation and capture command wiring
- unit tests for environment, inventory, status bar, screenshot, and settings services

Known MVP limitations:
- detects booted simulators only
- single simulator selection only
- no carrier name editing
- no open-save-folder action yet
- no presets or batch capture yet
- date visibility still depends on the simulator device family and the current app layout; iPhone usually shows only the time
- signal and network indicators are intentionally left on simulator defaults to avoid model-specific regressions

Next version candidates:
- carrier name editing
- open save folder
- persisted last-used status bar values
- optional auto-refresh

## Requirements

- macOS 15.0+
- Xcode 26.x recommended

## Build

```bash
swift build
```

## Run

```bash
swift run
```

The package can also be opened directly in Xcode.

## Install As App

To build a clickable macOS app bundle and install it to `~/Applications`:

```bash
./scripts/install_app.sh
```

This creates and installs:

```text
~/Applications/SimulatorHelper.app
```

After that, you can launch it by double-clicking the app icon in Finder. `Xcode` must be installed because the app uses `xcrun simctl`, but `Xcode.app` does not need to be open while you use Simulator Helper.

## Test

```bash
swift test
```

## Project Layout

```text
Sources/SimulatorHelper/
  App/
  Models/
  Services/
  ViewModels/
  Views/

Tests/SimulatorHelperTests/
```
