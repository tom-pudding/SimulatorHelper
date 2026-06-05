import SwiftUI
import Testing
@testable import SimulatorHelper

@MainActor
struct StatusBarFormViewTests {
    @Test
    func showsTimePickerAndBatteryControls() {
        let view = makeView(configuration: .defaultMVP)

        #expect(view.hasSelectedSimulator)
        #expect(view.capabilities.supportsMVP)
    }
}

@MainActor
private func makeView(configuration: StatusBarConfiguration) -> StatusBarFormView {
    StatusBarFormView(
        configuration: .constant(configuration),
        capabilities: sampleCapabilities,
        hasSelectedSimulator: true,
        isLoadingCapabilities: false,
        capabilitiesErrorMessage: nil,
        isPerformingAction: false,
        resultMessage: nil,
        resultIsError: false,
        onReloadCapabilities: {},
        onApply: {},
        onClear: {}
    )
}

private let sampleCapabilities = StatusBarCapabilities(
    supportedFlags: [.time, .batteryState, .batteryLevel],
    supportedDataNetworks: [],
    supportedWiFiModes: [],
    supportedCellularModes: [],
    supportedBatteryStates: ["charging", "charged", "discharging"],
    wifiBarsRange: 0...3,
    cellularBarsRange: 0...4,
    batteryLevelRange: 0...100
)
