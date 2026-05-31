import Testing
@testable import SimulatorHelper

struct StatusBarCapabilitiesServiceTests {
    @Test
    func parsesCurrentStatusBarHelpSurface() throws {
        let helpOutput = """
        Usage: simctl status_bar <device> [list | clear | override <override arguments>]
        --time <string>
        --dataNetwork <dataNetworkType>
             If specified must be one of 'hide', 'wifi', '3g', '4g', 'lte', 'lte-a', 'lte+', '5g', '5g+', '5g-uwb', or '5g-uc'.
        --wifiMode <mode>
             If specified must be one of 'searching', 'failed', or 'active'.
        --wifiBars <int>
             If specified must be 0-3.
        --cellularMode <mode>
             If specified must be one of 'notSupported', 'searching', 'failed', or 'active'.
        --cellularBars <int>
             If specified must be 0-4.
        --operatorName <string>
        --batteryState <state>
             If specified must be one of 'charging', 'charged', or 'discharging'.
        --batteryLevel <int>
             If specified must be 0-100.
        """

        let capabilities = try StatusBarCapabilitiesService().parseCapabilities(from: helpOutput)

        #expect(capabilities.supportedFlags.contains(.time))
        #expect(capabilities.supportedFlags.contains(.operatorName))
        #expect(capabilities.supportedDataNetworks.contains("5g"))
        #expect(capabilities.supportedDataNetworks.contains("5g-uwb"))
        #expect(capabilities.supportedWiFiModes == ["searching", "failed", "active"])
        #expect(capabilities.supportedCellularModes == ["notSupported", "searching", "failed", "active"])
        #expect(capabilities.supportedBatteryStates == ["charging", "charged", "discharging"])
        #expect(capabilities.wifiBarsRange == 0...3)
        #expect(capabilities.cellularBarsRange == 0...4)
        #expect(capabilities.batteryLevelRange == 0...100)
        #expect(capabilities.supportsMVP)
    }
}
