import Foundation
import Testing
@testable import SimulatorHelper

@MainActor
struct AppViewModelTests {
    @Test
    func selectingIPhoneForcesTimeOnlyMode() {
        let viewModel = AppViewModel()
        viewModel.simulators = [sampleIPadSimulator, sampleIPhoneSimulator]
        viewModel.selectedSimulatorID = sampleIPadSimulator.id
        viewModel.statusBarConfiguration.timeOverrideMode = .dateAndTime

        viewModel.selectedSimulatorID = sampleIPhoneSimulator.id

        #expect(viewModel.selectedSimulatorProductFamily == .iPhone)
        #expect(viewModel.allowsDateAndTimeOverride == false)
        #expect(viewModel.statusBarConfiguration.timeOverrideMode == .timeOnly)
    }

    @Test
    func clearingSelectionForcesTimeOnlyMode() {
        let viewModel = AppViewModel()
        viewModel.simulators = [sampleIPadSimulator]
        viewModel.selectedSimulatorID = sampleIPadSimulator.id
        viewModel.statusBarConfiguration.timeOverrideMode = .dateAndTime

        viewModel.selectedSimulatorID = nil

        #expect(viewModel.selectedSimulator == nil)
        #expect(viewModel.allowsDateAndTimeOverride == false)
        #expect(viewModel.statusBarConfiguration.timeOverrideMode == .timeOnly)
    }

    @Test
    func selectingIPadAllowsDateAndTimeMode() {
        let viewModel = AppViewModel()
        viewModel.simulators = [sampleIPadSimulator]
        viewModel.selectedSimulatorID = sampleIPadSimulator.id
        viewModel.statusBarConfiguration.timeOverrideMode = .dateAndTime

        #expect(viewModel.selectedSimulatorProductFamily == .iPad)
        #expect(viewModel.allowsDateAndTimeOverride)
        #expect(viewModel.statusBarConfiguration.timeOverrideMode == .dateAndTime)
    }
}

private let sampleIPhoneSimulator = SimulatorDescriptor(
    udid: "38C2AD9E-9318-445C-95CC-AAC69492FC2D",
    name: "iPhone 17 Pro",
    runtimeIdentifier: "com.apple.CoreSimulator.SimRuntime.iOS-26-3",
    runtimeName: "iOS 26.3",
    deviceTypeIdentifier: "com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro",
    productFamily: .iPhone,
    state: "Booted",
    lastBootedAt: ISO8601DateFormatter().date(from: "2026-05-31T12:39:20Z")
)

private let sampleIPadSimulator = SimulatorDescriptor(
    udid: "3FE64A14-8849-430C-87A4-1304F9E9F791",
    name: "iPad Pro 13-inch (M5)",
    runtimeIdentifier: "com.apple.CoreSimulator.SimRuntime.iOS-26-3",
    runtimeName: "iOS 26.3",
    deviceTypeIdentifier: "com.apple.CoreSimulator.SimDeviceType.iPad-Pro-13-inch-M5-12GB",
    productFamily: .iPad,
    state: "Booted",
    lastBootedAt: ISO8601DateFormatter().date(from: "2026-05-31T13:40:00Z")
)
