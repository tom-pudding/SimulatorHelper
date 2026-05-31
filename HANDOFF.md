# Simulator Helper Handoff

## Current Status

Completed:
- Phase 1 from `TASKS.md`

Not started:
- Phase 2 booted simulator discovery
- Phase 3 status bar controls
- Phase 4 screenshot workflow
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

## Build and Test

Use:

```bash
swift build
swift test
```

In this Codex environment, build and test commands require execution outside the default sandbox.

## Next Recommended Step

Start Phase 2 from `TASKS.md`:

1. decode `xcrun simctl list devices --json`
2. filter to booted iOS and iPadOS simulators
3. build the sidebar list
4. add single selection
5. add manual refresh
6. add the empty state for no booted simulators

## Notes

- The app currently uses a Swift package executable with a SwiftUI `App` entry point.
- Capability detection remains aligned with the approved architecture: trust the installed toolchain at runtime instead of assuming a fixed Xcode feature matrix.
