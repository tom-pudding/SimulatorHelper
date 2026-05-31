import SwiftUI

struct StatusBarFormView: View {
    @Binding var configuration: StatusBarConfiguration
    let capabilities: StatusBarCapabilities
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
                            label("Time")
                            TextField("9:41", text: $configuration.timeString)
                                .textFieldStyle(.roundedBorder)
                        }

                        GridRow {
                            label("Network Type")
                            Picker("Network Type", selection: $configuration.dataNetwork) {
                                ForEach(capabilities.availableMVPDataNetworks) { option in
                                    Text(option.title).tag(option)
                                }
                            }
                            .pickerStyle(.menu)
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
                    .disabled(isPerformingAction)

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
