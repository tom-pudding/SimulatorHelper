# Simulator Helper Handoff

## Current Status

Completed:
- Phase 1 from `TASKS.md`
- Phase 2 from `TASKS.md`
- Phase 3 from `TASKS.md`
- Phase 4 from `TASKS.md`

Not started:
- Phase 5 final verification and polish

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

## Build and Test

Use:

```bash
swift build
swift test
```

In this Codex environment, build and test commands require execution outside the default sandbox.

## Next Recommended Step

Start Phase 5 from `TASKS.md`:

1. verify behavior with current simulator states
2. review error handling and repeated action flows
3. update README and HANDOFF with final state
4. document any residual limitations

## Notes

- The app currently uses a Swift package executable with a SwiftUI `App` entry point.
- Capability detection remains aligned with the approved architecture: trust the installed toolchain at runtime instead of assuming a fixed Xcode feature matrix.
