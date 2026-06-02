# Simulator Helper Decision Registry v1.0

## Purpose

Preserve project-specific decision context, rationale, and course-correction history.

This registry is context, not law.

Use it to:
- understand why this app exists
- understand why certain features were intentionally not adopted
- avoid repeating already-rejected product debates without reason
- detect when changed conditions justify re-evaluation

AI behavior:
- respect relevant prior decisions
- do not follow them blindly
- if conditions changed, propose re-evaluation explicitly
- when changing course, add a new entry or supersede an old one

---

## Active Decisions Index

- SIMULATOR_HELPER-001 Keep the product focused on screenshot-preparation efficiency
- SIMULATOR_HELPER-002 Exclude Wi-Fi / Cellular / Signal Strength controls from the current scope
- SIMULATOR_HELPER-003 Use SimulatorHelper as an AI_ORG workflow validation project

---

## Entries

### [SIMULATOR_HELPER-001] Keep the product focused on screenshot-preparation efficiency

Status:
active

Scope:
SIMULATOR_HELPER

Type:
product

Date:
2026-06-02

Origin:
This app started from a practical frustration in App Store screenshot work: aligning simulator screenshots to `9:41` was annoying and repetitive.

Before building the app, some screenshots were fixed later through image editing or AI-based image correction. That worked, but it added cleanup work after capture instead of making screenshot preparation clean at the source.

The `9:41` problem is not just a small time-setting convenience. It is the original reason the app exists.

Context:
The real problem was not "general simulator control."
The real problem was reducing friction in screenshot preparation.

The app needed to help with:
- choosing a booted simulator
- normalizing status bar output for screenshots
- capturing screenshots into a predictable folder

Decision:
Keep Simulator Helper as a focused screenshot-preparation utility, not a general-purpose simulator management tool.

Included:
- simulator selection for booted devices
  - Why: directly supports screenshot preparation workflow
- time override support
  - Why: solves the original `9:41` problem directly
- screenshot capture flow
  - Why: completes the core workflow instead of stopping at status bar changes
- predictable save-folder workflow
  - Why: reduces post-capture friction
- battery support
  - Why: useful for screenshots while remaining relatively maintainable

Not Included:
- general simulator lifecycle management
  - Status: out-of-scope
  - Reason: broadens the product away from the screenshot-preparation goal
- broad simulator customization unrelated to screenshots
  - Status: out-of-scope
  - Reason: increases surface area without serving the main user pain directly
- relying on image editing or AI correction as the primary workflow
  - Status: rejected
  - Reason: fixes screenshots after the fact instead of making capture cleaner and more repeatable

Why:
- The app should solve the highest-value part of the workflow with the fewest moving parts.
- A narrow product is easier to keep reliable than a broad simulator control center.
- The original pain was screenshot preparation friction, not missing simulator power-user controls.

Tradeoffs:
- some advanced customization requests are intentionally deferred
- the app may feel limited to users wanting broader simulator control
- a narrower scope requires saying no to some plausible feature additions

Signals to Reconsider:
- repeated requests for non-screenshot simulator management features
  - Why it matters: may indicate the real product boundary should expand
- evidence that users primarily want a broader simulator control utility
  - Why it matters: would weaken the current product focus assumption
- the screenshot-preparation workflow no longer being the dominant use case
  - Why it matters: would challenge the current product purpose

If Reconsidered, Re-check:
- whether screenshot preparation is still the main user workflow
- whether broader controls would improve the product more than they would dilute it
- whether the UI can stay simple if scope expands

Related:
- `../README.md`
- `SIMULATOR_HELPER_HANDOFF.md`

Supersedes:
none

Superseded by:
none

Last reviewed:
2026-06-02

---

### [SIMULATOR_HELPER-002] Exclude Wi-Fi / Cellular / Signal Strength controls from the current scope

Status:
active

Scope:
SIMULATOR_HELPER

Type:
scope

Date:
2026-06-02

Origin:
Status bar customization naturally invites requests for Wi-Fi, cellular, and signal-strength controls.

These controls were considered during product shaping, but they raised a maintenance concern: simulator behavior varies by device family, screen layout, and Xcode version, and the project should avoid fragile UI that breaks often for limited product value.

Context:
SimulatorHelper uses `xcrun simctl` and must live with Apple simulator differences across Xcode updates and device families.

Some controls are more stable and higher-value than others.
Battery offered a better balance of usefulness and maintainability.
Wi-Fi / cellular / signal-strength styling introduced more variance and more potential regression risk.

Decision:
Do not include Wi-Fi, cellular, or signal-strength controls in the current product scope.

Keep battery support because it provides screenshot value without the same level of variability risk.

Included:
- battery level
  - Why: useful for screenshot preparation and comparatively maintainable
- derived battery state behavior
  - Why: keeps the feature useful while simplifying user-facing complexity

Not Included:
- Wi-Fi controls
  - Status: rejected
  - Reason: maintenance cost is too high relative to value because of device/layout/version variability
- cellular mode controls
  - Status: rejected
  - Reason: same variability problem, with higher regression risk across simulator environments
- signal strength controls
  - Status: rejected
  - Reason: visual differences across devices and Xcode updates make the feature expensive to trust
- broad network-indicator customization
  - Status: rejected
  - Reason: pulls the app toward high-maintenance simulator styling instead of efficient screenshot preparation

Why:
- These controls are exactly the kind of feature that future AI sessions may try to re-add unless the non-adoption reason is documented.
- The project benefits more from stable screenshot workflow improvements than from fragile indicator-level customization.
- Battery is a better compromise because it is useful in screenshots and less exposed to device-specific UI inconsistency.

Tradeoffs:
- users lose some fine-grained screenshot styling control
- some App Store screenshot scenarios may still need manual handling outside the app
- the app intentionally leaves some simulator defaults untouched

Signals to Reconsider:
- repeated requests for Wi-Fi / cellular controls across separate user sessions
  - Why it matters: may indicate real demand exceeds the current maintenance concern
- Apple simulator behavior becomes more stable across device families and Xcode versions
  - Why it matters: lowers maintenance risk
- the implementation cost drops because capability detection or validation becomes more robust
  - Why it matters: changes the value-to-cost balance
- manual screenshot cleanup for network indicators becomes a recurring pain again
  - Why it matters: suggests the excluded features may now solve a real repeated problem

If Reconsidered, Re-check:
- whether simulator rendering is stable across at least one iPhone and one iPad family
- whether the same controls behave consistently across the current supported Xcode range
- whether the feature still fits the app's core screenshot-preparation purpose
- whether the UI can add those controls without becoming cluttered

Related:
- `../README.md`
- `SIMULATOR_HELPER_HANDOFF.md`
- `SIMULATOR_HELPER-001`

Supersedes:
none

Superseded by:
none

Last reviewed:
2026-06-02

---

### [SIMULATOR_HELPER-003] Use SimulatorHelper as an AI_ORG workflow validation project

Status:
active

Scope:
SIMULATOR_HELPER

Type:
process

Date:
2026-06-02

Origin:
SimulatorHelper has been used not only as an app project, but also as a practical environment for validating AI_ORG workflow patterns.

It provided a real project where design-first collaboration, scoped implementation, verification, review, and handoff continuity could be tested instead of treated as abstract policy.

Context:
AI_ORG is building operating rules for multi-AI development.

A live project was needed to validate:
- design -> proposal -> scoped implementation -> verification -> review
- handoff quality
- documentation strategy
- narrow reversible change control
- cross-session continuity

Decision:
Treat SimulatorHelper as both:
- a real product project
- a validation project for AI_ORG workflow practice

Included:
- design-first workflow
  - Why: reduces premature implementation and keeps scope explicit
- proposal before implementation for meaningful changes
  - Why: improves clarity and reduces rework
- scoped implementation
  - Why: keeps changes reversible and reviewable
- verification and review phases
  - Why: improves reliability and documentation quality

Not Included:
- fully improvisational implementation flow
  - Status: rejected
  - Reason: makes scope drift and decision loss more likely
- skipping verification when the change seems small
  - Status: rejected
  - Reason: weakens the project's role as a workflow validation case
- treating workflow documentation as optional
  - Status: rejected
  - Reason: removes the learning value that this project provides to AI_ORG

Why:
- SimulatorHelper is small enough to be manageable and real enough to expose workflow weaknesses.
- Using a real project for process validation produces better AI_ORG rules than designing them in isolation.
- This project has already surfaced useful lessons about handoff clarity, documentation naming, and preserving rationale.

Tradeoffs:
- workflow discipline adds overhead compared with pure ad hoc coding
- documentation effort is higher than in a throwaway utility
- some process steps may feel heavier than strictly necessary for tiny changes

Signals to Reconsider:
- the workflow overhead repeatedly exceeds its value on this project
  - Why it matters: may suggest the process is too heavy for the project size
- AI_ORG begins validating workflow more effectively in another project
  - Why it matters: SimulatorHelper may no longer need to carry this role
- the current workflow stops improving decision quality or handoff quality
  - Why it matters: would weaken the reason for using this project as a validation case

If Reconsidered, Re-check:
- whether this project still provides useful workflow lessons
- whether the current process is proportionate to project size
- whether another project has become the better AI_ORG validation environment

Related:
- `SIMULATOR_HELPER_HANDOFF.md`
- `../README.md`
- `~/AI_ORG/DECISION_REGISTRY.md`

Supersedes:
none

Superseded by:
none

Last reviewed:
2026-06-02
