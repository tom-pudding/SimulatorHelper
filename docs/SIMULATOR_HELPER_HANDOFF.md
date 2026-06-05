# Simulator Helper Handoff

## Source of Truth

Use this file together with `../README.md` as the current source of truth for implemented behavior and current project status.

Older planning documents are preserved as historical references only:
- `SIMULATOR_HELPER_PRODUCT_HISTORICAL.md`
- `SIMULATOR_HELPER_ARCHITECTURE_HISTORICAL.md`
- `SIMULATOR_HELPER_TASKS_HISTORICAL.md`
- `SIMULATOR_HELPER_RISKS_HISTORICAL.md`

Those historical docs may not match the current implementation exactly.

## Current Status

Completed:
- Phase 1 from `SIMULATOR_HELPER_TASKS_HISTORICAL.md`
- Phase 2 from `SIMULATOR_HELPER_TASKS_HISTORICAL.md`
- Phase 3 from `SIMULATOR_HELPER_TASKS_HISTORICAL.md`
- Phase 4 from `SIMULATOR_HELPER_TASKS_HISTORICAL.md`
- Phase 5 from `SIMULATOR_HELPER_TASKS_HISTORICAL.md`
- Version 1.1 implementation pass for persisted settings, open-save-folder flow, and validation hardening

Not yet manually verified:
- visible time/date and battery appearance across at least one iPhone and one iPad simulator

Approved Version 1.1 direction:
- do not implement carrier name editing in Version 1.1
- keep carrier name editing deferred unless real user demand or repeated workflow pain is confirmed
- prioritize:
  1. persisted last-used status bar values
  2. open-save-folder action
  3. validation hardening
- keep optional auto-refresh below those items

Latest completed follow-up:
- added `Date + Time` status bar override mode for iPad-relevant screenshot cases
- kept `Time Only` mode for standard iPhone screenshot workflows
- made `Date + Time` unavailable unless an iPad simulator is selected
- removed signal and network controls from the UI so simulator defaults remain untouched across device models
- kept only battery level as the non-time override, with battery state derived automatically
- added scripts to build `SimulatorHelper.app` and install it into `~/Applications` for normal Finder-based launching
- persisted last-used status bar form values and restored them on launch
- added an `Open Save Folder` action that prepares and opens the current destination folder
- kept save-folder actions available even without a selected simulator while keeping screenshot capture gated by simulator selection
- expanded tests for persisted settings, folder opening, parser drift, and view-model behavior

## What Phase 1 Added

- Swift package-backed macOS SwiftUI app scaffold
- MVVM-oriented directory structure
- `SystemProcessRunner` for shell command execution
- `EnvironmentService` that checks:
  - `xcodebuild -version`
  - `xcode-select -p`
  - `xcrun --find simctl`
  - `xcrun simctl help status_bar`
- initial UI showing environment readiness and toolchain details
- environment-layer tests using a stubbed process runner

## What Phase 2 Added

- `SimulatorInventoryService` backed by `xcrun simctl list devices --json`
- filtering for booted iPhone and iPad simulators only
- stable sorting for returned simulators
- sidebar selection state for one active simulator
- manual simulator refresh action
- selected-simulator detail card in the main panel
- simulator inventory tests using stubbed JSON

## What Phase 3 Added

- `StatusBarCapabilitiesService` that parses `xcrun simctl help status_bar`
- `StatusBarCapabilities` and `StatusBarConfiguration` models
- validated `StatusBarCommandService` for apply and clear operations
- MVP status bar form UI for:
  - time
  - network type
  - Wi-Fi mode and bars
  - cellular mode and bars
  - battery state and level
- status bar capability and command tests

## What Phase 4 Added

- `AppSettingsStore` for screenshot folder persistence
- default screenshot folder at `~/Desktop/Simulator Helper`
- `FolderSelectionService` using a native macOS folder chooser
- `ScreenshotService` for filename generation and `simctl io screenshot`
- screenshot UI section with folder selection and capture actions
- screenshot and settings store tests

## What Phase 5 Finalized

- final MVP build/test verification pass
- README updated to reflect completed MVP scope
- HANDOFF updated for future version work
- residual MVP limitations documented

## Post-MVP Status Bar Follow-up

- `StatusBarConfiguration` now supports:
  - `Time Only`
  - `Date + Time`
- `Date + Time` is serialized as a local ISO-like string for `simctl`
- the status bar form now limits overrides to:
  - time
  - date on iPad layouts
  - battery level
- `batteryState` is no longer user-editable:
  - `100%` maps to `charged`
  - lower values map to `discharging`
- tests now cover:
  - free-form time strings
  - local date/time override string generation
  - automatic battery state selection
  - forcing `Time Only` when an iPhone or no simulator is selected

## Version 1.1 Implementation Notes

- `AppSettingsStore` now persists status bar form values in addition to the screenshot folder
- launch now restores the last-used status bar form values before runtime normalization
- screenshot-folder actions are now split from screenshot capture:
  - folder selection and folder opening remain available without a selected simulator
  - screenshot capture still requires a selected booted simulator
- folder opening prepares the target directory before attempting to open it
- `StatusBarCapabilitiesService` parsing is hardened for double-quoted value lists and ellipsis-style numeric ranges
- `swift test` currently passes with the expanded Version 1.1 coverage

## Build and Test

Use:

```bash
swift build
swift test
```

To build and install a clickable app bundle:

```bash
./scripts/install_app.sh
```

In this Codex environment, build and test commands require execution outside the default sandbox.

## Next Recommended Step

Next recommended step:

Manually validate the implemented Version 1.1 behavior across at least one iPhone and one iPad simulator:

1. confirm restored values behave correctly on relaunch
2. confirm `Open Save Folder` opens the configured destination cleanly
3. confirm visible time/date and battery results on current simulator screens
4. update docs only if the manual findings differ from the current assumptions

Deferred for now:

- carrier name editing
  - reason: low current need and weaker alignment with the screenshot-preparation focus
  - revisit only if user demand or repeated real workflow pain becomes clear
- optional auto-refresh
  - reason: still useful, but not ahead of persistence, open-folder flow, or validation hardening

## Notes

- The app currently uses a Swift package executable with a SwiftUI `App` entry point.
- Normal end-user launching is now via `~/Applications/SimulatorHelper.app` after running `./scripts/install_app.sh`.
- `Xcode` must be installed because the app shells out to `xcrun simctl`, but `Xcode.app` does not need to stay open.
- Capability detection remains aligned with the approved architecture: trust the installed toolchain at runtime instead of assuming a fixed Xcode feature matrix.
- Manual UI verification is still recommended for how date visibility appears on iPad layouts, because `simctl` support does not guarantee the current app screen shows the date.
