# Simulator Helper

Simulator Helper is a native macOS SwiftUI utility for configuring iOS Simulator status bar settings and capturing screenshots without using Terminal.

## Documentation Status

Current source of truth for the implemented app:
- `README.md`
- `docs/SIMULATOR_HELPER_HANDOFF.md`

Historical planning references:
- `docs/SIMULATOR_HELPER_PRODUCT_HISTORICAL.md`
- `docs/SIMULATOR_HELPER_ARCHITECTURE_HISTORICAL.md`
- `docs/SIMULATOR_HELPER_TASKS_HISTORICAL.md`
- `docs/SIMULATOR_HELPER_RISKS_HISTORICAL.md`

Those historical planning docs are preserved for context and may not match the current implementation exactly.

## Current Status

MVP implementation is complete.
Version 1.1 code changes are implemented.
Manual simulator validation of visible status bar output is still recommended.

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
- persisted last-used status bar values
- open-save-folder action that prepares and opens the current destination folder
- screenshot filename generation and capture command wiring
- expanded unit tests for environment, inventory, status bar, screenshot, settings, folder-opening, and view-model flows

Known current limitations:
- detects booted simulators only
- single simulator selection only
- no carrier name editing
- no presets or batch capture yet
- date visibility still depends on the simulator device family and the current app layout; iPhone usually shows only the time
- signal and network indicators are intentionally left on simulator defaults to avoid model-specific regressions
- manual iPhone/iPad visual verification is still recommended for time/date and battery appearance

Version 1.1 implemented in code:
1. persist last-used status bar values
2. open save folder
3. validation hardening for capability parsing and screenshot workflow edge cases

Deferred for now:
- carrier name editing
  - reason: low current need and low contribution to screenshot-preparation efficiency
  - reconsider if real user demand or repeated workflow pain is confirmed
- optional auto-refresh
  - reason: lower priority than persistence, open-folder flow, and validation hardening

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
