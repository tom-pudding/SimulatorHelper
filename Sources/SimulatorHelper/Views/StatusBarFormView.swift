import SwiftUI

struct StatusBarFormView: View {
    private let modeControlWidth: CGFloat = 280

    @Binding var configuration: StatusBarConfiguration
    let capabilities: StatusBarCapabilities
    let allowsDateAndTimeOverride: Bool
    let hasSelectedSimulator: Bool
    let isLoadingCapabilities: Bool
    let capabilitiesErrorMessage: String?
    let isPerformingAction: Bool
    let resultMessage: String?
    let resultIsError: Bool
    let onReloadCapabilities: () -> Void
    let onApply: () -> Void
    let onClear: () -> Void

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
                            Text("")
                                .accessibilityHidden(true)
                            timeOverrideControls
                        }

                        GridRow {
                            label("Battery")
                            batteryLevelControls
                        }
                    }

                    HStack(spacing: 12) {
                        Button("Apply Settings", action: onApply)
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
        VStack(alignment: .leading, spacing: 8) {
            Picker("", selection: $configuration.timeOverrideMode) {
                ForEach(StatusBarConfiguration.TimeOverrideMode.allCases) { option in
                    Text(option.title)
                        .tag(option)
                        .disabled(option == .dateAndTime && !allowsDateAndTimeOverride)
                }
            }
            .labelsHidden()
            .pickerStyle(.segmented)
            .frame(width: modeControlWidth, alignment: .leading)

            if configuration.timeOverrideMode == .timeOnly {
                HStack(spacing: 12) {
                    TextField("9:41", text: $configuration.timeString)
                        .textFieldStyle(.roundedBorder)
                        .frame(minWidth: 160)

                    Button("Use 9:41") {
                        configuration.timeString = "9:41"
                    }
                    .buttonStyle(.bordered)
                    .disabled(isPerformingAction)
                }
            } else {
                HStack(alignment: .top, spacing: 12) {
                    DatePicker(
                        "Date",
                        selection: $configuration.dateAndTimeOverride,
                        displayedComponents: [.date]
                    )

                    DatePicker(
                        "Time",
                        selection: $configuration.dateAndTimeOverride,
                        displayedComponents: [.hourAndMinute]
                    )

                    Button("Use Today 9:41") {
                        configuration.dateAndTimeOverride = StatusBarConfiguration.defaultDateAndTimeOverride()
                    }
                    .buttonStyle(.bordered)
                    .disabled(isPerformingAction)
                }
            }
        }
    }

    private var batteryLevelControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Stepper(value: $configuration.batteryLevel, in: capabilities.batteryLevelRange) {
                Text("\(configuration.batteryLevel)%")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
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
