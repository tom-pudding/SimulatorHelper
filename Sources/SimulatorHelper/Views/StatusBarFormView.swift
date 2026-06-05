import SwiftUI

struct StatusBarFormView: View {
    @Binding var configuration: StatusBarConfiguration
    let capabilities: StatusBarCapabilities
    let hasSelectedSimulator: Bool
    let isLoadingCapabilities: Bool
    let capabilitiesErrorMessage: String?
    let isPerformingAction: Bool
    let resultMessage: String?
    let resultIsError: Bool
    let onReloadCapabilities: () -> Void
    let onApply: () -> Void
    let onClear: () -> Void

    @State private var timeText: String

    init(
        configuration: Binding<StatusBarConfiguration>,
        capabilities: StatusBarCapabilities,
        hasSelectedSimulator: Bool,
        isLoadingCapabilities: Bool,
        capabilitiesErrorMessage: String?,
        isPerformingAction: Bool,
        resultMessage: String?,
        resultIsError: Bool,
        onReloadCapabilities: @escaping () -> Void,
        onApply: @escaping () -> Void,
        onClear: @escaping () -> Void
    ) {
        self._configuration = configuration
        self.capabilities = capabilities
        self.hasSelectedSimulator = hasSelectedSimulator
        self.isLoadingCapabilities = isLoadingCapabilities
        self.capabilitiesErrorMessage = capabilitiesErrorMessage
        self.isPerformingAction = isPerformingAction
        self.resultMessage = resultMessage
        self.resultIsError = resultIsError
        self.onReloadCapabilities = onReloadCapabilities
        self.onApply = onApply
        self.onClear = onClear
        self._timeText = State(initialValue: "")
    }

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 18) {
                if isLoadingCapabilities {
                    ProgressView("Loading status bar capabilities…")
                        .progressViewStyle(.linear)
                } else if let capabilitiesErrorMessage {
                    statusMessage(message: capabilitiesErrorMessage, symbolName: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                    Button("Retry Capability Detection", action: onReloadCapabilities)
                } else if !capabilities.supportsMVP {
                    statusMessage(
                        message: "The active toolchain is missing one or more required status bar options.",
                        symbolName: "exclamationmark.triangle"
                    )
                    .foregroundStyle(.orange)
                } else {
                    Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 14) {
                        GridRow {
                            label("Time")
                            timeOverrideControls
                        }
                        GridRow {
                            label("Battery")
                            batteryLevelControls
                        }
                    }

                    HStack(spacing: 12) {
                        Button("Apply Settings") {
                            commitTimeText()
                            onApply()
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Clear Overrides", action: onClear)
                            .buttonStyle(.bordered)
                    }
                    .disabled(isPerformingAction || !hasSelectedSimulator)

                    if !hasSelectedSimulator {
                        statusMessage(
                            message: "Edit values freely, then select a booted simulator to apply or clear overrides.",
                            symbolName: "info.circle"
                        )
                        .foregroundStyle(.secondary)
                    }

                    if let resultMessage {
                        statusMessage(
                            message: resultMessage,
                            symbolName: resultIsError ? "xmark.octagon" : "checkmark.seal"
                        )
                        .foregroundStyle(resultIsError ? .red : .green)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            Label("Status Bar", systemImage: "switch.2")
        }
    }

    private var timeOverrideControls: some View {
        HStack(spacing: 12) {
            TextField("", text: $timeText)
                .frame(width: 72)
                .textFieldStyle(.roundedBorder)
                .onSubmit { commitTimeText() }

            Button("Use 9:41") {
                configuration.resetTimeToDefault()
                timeText = "9:41"
            }
            .buttonStyle(.bordered)
            .disabled(isPerformingAction)
        }
        .onChange(of: configuration.timeOverride) { _, _ in
            timeText = configuration.resolvedTimeString
        }
    }

    private var batteryLevelControls: some View {
        Stepper(value: $configuration.batteryLevel, in: capabilities.batteryLevelRange) {
            Text("\(configuration.batteryLevel)%")
        }
        .fixedSize()
    }

    private func commitTimeText() {
        if let (hour, minute) = parseTime(timeText) {
            var components = Calendar.current.dateComponents([.year, .month, .day], from: configuration.timeOverride)
            components.hour = hour
            components.minute = minute
            components.second = 0
            if let date = Calendar.current.date(from: components) {
                configuration.timeOverride = date
            }
            timeText = String(format: "%d:%02d", hour, minute)
        } else {
            timeText = ""
        }
    }

    // Accepts "9:41", "09:41" (with colon) or "941", "0941" (digits only).
    // 3 digits → first digit is hour, last two are minutes.
    // 4 digits → first two digits are hour, last two are minutes.
    private func parseTime(_ input: String) -> (hour: Int, minute: Int)? {
        let trimmed = input.trimmingCharacters(in: .whitespaces)

        if trimmed.contains(":") {
            let parts = trimmed.split(separator: ":", maxSplits: 1)
            guard parts.count == 2,
                  let hour = Int(parts[0]),
                  let minute = Int(String(parts[1])),
                  (0...23).contains(hour),
                  (0...59).contains(minute) else { return nil }
            return (hour, minute)
        }

        let digits = trimmed.filter { $0.isNumber }
        switch digits.count {
        case 3:
            guard let hour = Int(String(digits.prefix(1))),
                  let minute = Int(String(digits.suffix(2))),
                  (0...23).contains(hour),
                  (0...59).contains(minute) else { return nil }
            return (hour, minute)
        case 4:
            guard let hour = Int(String(digits.prefix(2))),
                  let minute = Int(String(digits.suffix(2))),
                  (0...23).contains(hour),
                  (0...59).contains(minute) else { return nil }
            return (hour, minute)
        default:
            return nil
        }
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .foregroundStyle(.secondary)
    }

    private func statusMessage(message: String, symbolName: String) -> some View {
        Label {
            Text(message)
                .fixedSize(horizontal: false, vertical: true)
        } icon: {
            Image(systemName: symbolName)
        }
        .font(.callout)
    }
}
