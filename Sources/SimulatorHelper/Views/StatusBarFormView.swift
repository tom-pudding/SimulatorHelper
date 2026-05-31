import SwiftUI

struct StatusBarFormView: View {
    @Binding var configuration: StatusBarConfiguration
    let capabilities: StatusBarCapabilities
    let selectedProductFamily: SimulatorDescriptor.ProductFamily?
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
                        message: "The active toolchain is missing one or more MVP status bar options.",
                        symbolName: "exclamationmark.triangle"
                    )
                    .foregroundStyle(.orange)
                } else {
                    Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 14) {
                        GridRow {
                            label("Date/Time")
                            timeOverrideControls
                        }

                        GridRow {
                            label("Network Type")
                            networkTypeControls
                        }

                        GridRow {
                            label("Wi-Fi Mode")
                            Picker("Wi-Fi Mode", selection: $configuration.wifiMode) {
                                ForEach(capabilities.availableWiFiModes) { option in
                                    Text(option.title).tag(option)
                                }
                            }
                            .pickerStyle(.menu)
                        }

                        GridRow {
                            label("Wi-Fi Bars")
                            Stepper(value: $configuration.wifiBars, in: capabilities.wifiBarsRange) {
                                Text("\(configuration.wifiBars)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        GridRow {
                            label("Cellular Mode")
                            Picker("Cellular Mode", selection: $configuration.cellularMode) {
                                ForEach(capabilities.availableCellularModes) { option in
                                    Text(option.title).tag(option)
                                }
                            }
                            .pickerStyle(.menu)
                        }

                        GridRow {
                            label("Cellular Bars")
                            Stepper(value: $configuration.cellularBars, in: capabilities.cellularBarsRange) {
                                Text("\(configuration.cellularBars)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        GridRow {
                            label("Battery State")
                            Picker("Battery State", selection: $configuration.batteryState) {
                                ForEach(capabilities.availableBatteryStates) { option in
                                    Text(option.title).tag(option)
                                }
                            }
                            .pickerStyle(.menu)
                        }

                        GridRow {
                            label("Battery Level")
                            Stepper(value: $configuration.batteryLevel, in: capabilities.batteryLevelRange) {
                                Text("\(configuration.batteryLevel)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
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
            if allowsDateAndTimeOverride {
                Picker("Date/Time", selection: $configuration.timeOverrideMode) {
                    ForEach(StatusBarConfiguration.TimeOverrideMode.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 280)
            } else {
                HStack(spacing: 8) {
                    modeChip(title: "Time Only", isSelected: true, isDisabled: false)
                    modeChip(title: "Date + Time", isSelected: false, isDisabled: true)
                }
            }

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

                Text(timeOnlyHelperText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
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

                Text("Some iPad layouts show the date next to the time.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var networkTypeControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Picker("Network Type", selection: $configuration.dataNetwork) {
                ForEach(capabilities.availableDataNetworks) { option in
                    Text(option.title).tag(option)
                }
            }
            .pickerStyle(.menu)

            Text("Network Type controls labels like Wi-Fi, LTE, and 5G. Wi-Fi Mode only changes the Wi-Fi icon state.")
                .font(.caption)
                .foregroundStyle(.secondary)

            if selectedProductFamily == .iPhone {
                Text("Simulator output still varies by iPhone model. Newer iPhone layouts can keep the Wi-Fi glyph even when a cellular network override is active.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var timeOnlyHelperText: String {
        if selectedProductFamily == .iPhone {
            return "Date + Time is unavailable on iPhone because the standard iPhone status bar shows only the time."
        }

        if selectedProductFamily == nil {
            return "Select an iPad simulator to enable Date + Time. Time Only works for all supported simulators."
        }

        return "Use a simple time string for the standard status bar clock."
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .foregroundStyle(.secondary)
    }

    private func modeChip(title: String, isSelected: Bool, isDisabled: Bool) -> some View {
        Text(title)
            .font(.subheadline.weight(.medium))
            .foregroundColor(isDisabled ? .secondary : (isSelected ? .white : .primary))
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(isDisabled ? Color.secondary.opacity(0.15) : (isSelected ? Color.accentColor : Color.secondary.opacity(0.12)))
            )
            .overlay(
                Capsule()
                    .strokeBorder(Color.secondary.opacity(isDisabled ? 0.2 : 0), lineWidth: 1)
            )
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
