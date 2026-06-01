# Historical Planning Document

This file is a preserved historical planning artifact.

It may not match the current implementation exactly.

Use `../README.md` and `SIMULATOR_HELPER_HANDOFF.md` for the current project state.

---

# Simulator Helper Risks

## 1. Key Risks

| Risk | Impact | Likelihood | Mitigation |
|---|---|---:|---|
| `simctl` output changes across Xcode releases | High | Medium | Parse runtime capabilities from the installed toolchain instead of hard-coding all options |
| Public docs do not expose a complete `status_bar` flag matrix for every Xcode point release | High | High | Treat local `xcrun simctl help status_bar` output as the source of truth at runtime |
| Status bar overrides may be incorrect on some runtimes | High | Medium | Surface Xcode version in the UI and document the known issue from Xcode 15 release notes |
| Commands fail on shutdown simulators | High | High | Detect booted simulators only and disable actions otherwise |
| Some simulator screens hide the status bar | Medium | High | Explain that command success does not always equal visible UI change on the current screen |
| iPhone and iPad layout differences change the visible result | Medium | Medium | Test both device families and avoid promising pixel-identical output |
| GitHub Releases distribution may trigger trust friction if the app is unsigned or not notarized | High | Medium | Sign and notarize before publishing releases |
| Wrong active Xcode or broken command-line tool configuration | High | Medium | Show active Xcode version and fail with actionable guidance |
| Process concurrency can trigger double-runs or confusing button state | Medium | Medium | Serialize actions per selected simulator and disable actions while running |
| MVP scope can drift back toward a general simulator control center | Medium | High | Keep lifecycle controls, presets, and batch operations out of MVP |

## 2. Current Constraints Backed by Verification

As of **May 31, 2026**:

1. Apple’s support matrix lists **Xcode 26.5** as the current Xcode release family.
2. Direct local verification was run on **Xcode 26.2 (17C52)**.
3. `simctl status_bar` supports:
   - `time`
   - `dataNetwork`
   - `wifiMode`
   - `wifiBars`
   - `cellularMode`
   - `cellularBars`
   - `operatorName`
   - `batteryState`
   - `batteryLevel`
4. The verified local toolchain supports `5g`, `5g+`, `5g-uwb`, and `5g-uc`.
5. `simctl status_bar` fails on shutdown simulators.
6. `simctl io screenshot` works on booted simulators.
7. Apple introduced `simctl status_bar` in Xcode 11.
8. Apple added `operatorName` support in Xcode 11.4.
9. Xcode 15 release notes document a known issue where status bar overrides may be set incorrectly when using iOS 14 or later simulator runtimes.

## 3. Distribution Risks

### Risk: poor first-run trust experience from GitHub Releases
Why it matters:
- If the app is distributed unsigned or unnotarized, users may hit Gatekeeper warnings.

Mitigation:
- Developer ID sign and notarize the app before publishing releases.

### Risk: future move to Mac App Store changes technical assumptions
Why it matters:
- The current architecture is intentionally optimized for GitHub Releases, not App Store sandboxing.

Mitigation:
- Keep that future move explicitly out of MVP planning.
- Re-review process execution and file-access assumptions if distribution changes later.

## 4. Product Risks

### Risk: over-scoped first release
Why it matters:
- The original request includes many possible knobs, but the real problem is faster screenshot preparation.

Mitigation:
- Keep MVP to a curated subset of status bar controls.
- Move carrier name, advanced network variants, and convenience features to later versions.

### Risk: too much UI for too little value
Why it matters:
- A large form increases friction and weakens the product’s main advantage over Terminal.

Mitigation:
- Keep the first window short, clear, and action-oriented.
- Expose only the subset needed for common screenshot normalization.

## 5. Technical Risks

### Risk: fragile parsing
Problem:
- Some `simctl` outputs are structured JSON, while others are plain text help output.

Mitigation:
- Use JSON where available.
- Restrict plain-text parsing to `help status_bar`.
- Avoid building MVP features that require parsing `status_bar list` back into structured form values.

### Risk: misleading success states
Problem:
- The command can succeed even when the current simulator screen does not visibly show the status bar.

Mitigation:
- Phrase success messages carefully.
- Do not promise visible UI change on every current screen.

### Risk: mismatch between current Apple release family and the locally verified installed toolchain
Problem:
- Apple’s current release family is `26.5`, but direct local verification in this environment is on `26.2`.

Mitigation:
- Call out the exact verified version in documentation.
- Detect capabilities dynamically at runtime instead of assuming `26.5` behavior.

## 6. Risk Posture Recommendation

Recommended posture:

1. keep MVP narrow
2. trust the installed toolchain, not assumptions
3. prefer explicit environment diagnostics
4. ship signed and notarized GitHub releases

## 7. Sources

### Apple documentation
- Xcode support matrix  
  https://developer.apple.com/support/xcode/

- Xcode 26.5 Release Notes  
  https://developer.apple.com/documentation/xcode-release-notes/xcode-26_5-release-notes

- Xcode 15 Release Notes  
  https://developer.apple.com/documentation/xcode-release-notes/xcode-15-release-notes

- Xcode 11 Release Notes  
  https://developer.apple.com/documentation/Xcode-Release-Notes/xcode-11-release-notes

- Xcode 11.4 Release Notes  
  https://developer.apple.com/documentation/xcode-release-notes/xcode-11_4-release-notes

- WWDC20: Become a Simulator expert  
  https://developer.apple.com/videos/play/wwdc2020/10647/

- Foundation `NSTask` / `Process`  
  https://developer.apple.com/documentation/foundation/nstask

### Local verification on May 31, 2026
- `xcodebuild -version`
- `xcrun simctl help status_bar`
- `xcrun simctl help io`
