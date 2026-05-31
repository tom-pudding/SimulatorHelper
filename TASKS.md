# Simulator Helper Task Breakdown

## 1. MVP Task List

### Milestone 1: Project Shell
1. Create the native macOS SwiftUI app target
2. Establish MVVM structure
3. Add a shared `ProcessRunner`
4. Add `EnvironmentService`
5. Show Xcode/toolchain readiness in the UI

### Milestone 2: Booted Simulator Discovery
1. Decode `xcrun simctl list devices --json`
2. Filter to booted iOS and iPadOS simulators only
3. Build the sidebar list
4. Add single selection
5. Add manual refresh
6. Add the empty state for no booted simulators

### Milestone 3: MVP Status Bar Controls
1. Parse `xcrun simctl help status_bar`
2. Build the capability model
3. Build the MVP form only:
   - time
   - network type
   - Wi-Fi mode and bars
   - cellular mode and bars
   - battery state and level
4. Validate ranges and required values
5. Implement `Apply Settings`
6. Implement `Clear Overrides`

### Milestone 4: Screenshot Workflow
1. Add folder picker flow
2. Persist the chosen folder
3. Generate the screenshot filename
4. Implement `simctl io screenshot`
5. Show success and failure messages clearly

### Milestone 5: MVP Verification
1. Test with no booted simulators
2. Test with one booted iPhone simulator
3. Test with one booted iPad simulator
4. Test environment failure states
5. Test repeated apply and capture operations

## 2. Version 1.1 Backlog

1. Add carrier name editing
2. Add advanced data network variants:
   - `hide`
   - `lte-a`
   - `lte+`
   - `5g+`
   - `5g-uwb`
   - `5g-uc`
3. Add `Open Save Folder`
4. Persist last-used form values
5. Add optional auto-refresh polling
6. Improve post-capture feedback with saved-path details

## 3. Version 1.2 Backlog

1. Add presets
2. Add saved configuration profiles
3. Add App Store Screenshot Mode
4. Add batch capture across multiple simulators
5. Add screenshot session management
6. Add App Store Connect asset helper

## 4. Recommended Implementation Order

1. Environment validation
2. Booted simulator discovery
3. Status bar capability detection
4. MVP form and apply/clear
5. Screenshot folder flow
6. Screenshot capture
7. MVP verification

## 5. Approval Checkpoints During Implementation

Pause after:

1. environment banner works
2. booted simulator list works
3. apply and clear work
4. screenshot capture works

These are the highest-signal checkpoints where visible behavior can be approved before continuing.
