import Foundation

struct StatusBarConfiguration: Equatable, Sendable {
    enum DataNetworkOption: String, CaseIterable, Identifiable, Sendable {
        case wifi
        case threeG = "3g"
        case fourG = "4g"
        case lte
        case fiveG = "5g"

        var id: String { rawValue }

        var title: String {
            switch self {
            case .wifi:
                return "Wi-Fi"
            case .threeG:
                return "3G"
            case .fourG:
                return "4G"
            case .lte:
                return "LTE"
            case .fiveG:
                return "5G"
            }
        }
    }

    enum WiFiModeOption: String, CaseIterable, Identifiable, Sendable {
        case searching
        case failed
        case active

        var id: String { rawValue }

        var title: String {
            rawValue.capitalized
        }
    }

    enum CellularModeOption: String, CaseIterable, Identifiable, Sendable {
        case notSupported
        case searching
        case failed
        case active

        var id: String { rawValue }

        var title: String {
            switch self {
            case .notSupported:
                return "Not Supported"
            case .searching:
                return "Searching"
            case .failed:
                return "Failed"
            case .active:
                return "Active"
            }
        }
    }

    enum BatteryStateOption: String, CaseIterable, Identifiable, Sendable {
        case charging
        case charged
        case discharging

        var id: String { rawValue }

        var title: String {
            rawValue.capitalized
        }
    }

    var timeString: String
    var dataNetwork: DataNetworkOption
    var wifiMode: WiFiModeOption
    var wifiBars: Int
    var cellularMode: CellularModeOption
    var cellularBars: Int
    var batteryState: BatteryStateOption
    var batteryLevel: Int

    static let defaultMVP = StatusBarConfiguration(
        timeString: "9:41",
        dataNetwork: .wifi,
        wifiMode: .active,
        wifiBars: 3,
        cellularMode: .active,
        cellularBars: 4,
        batteryState: .charged,
        batteryLevel: 100
    )

    mutating func normalize(using capabilities: StatusBarCapabilities) {
        if let firstSupportedNetwork = capabilities.availableMVPDataNetworks.first,
           !capabilities.availableMVPDataNetworks.contains(dataNetwork) {
            dataNetwork = firstSupportedNetwork
        }

        if let firstSupportedWiFiMode = capabilities.availableWiFiModes.first,
           !capabilities.availableWiFiModes.contains(wifiMode) {
            wifiMode = firstSupportedWiFiMode
        }

        if let firstSupportedCellularMode = capabilities.availableCellularModes.first,
           !capabilities.availableCellularModes.contains(cellularMode) {
            cellularMode = firstSupportedCellularMode
        }

        if let firstSupportedBatteryState = capabilities.availableBatteryStates.first,
           !capabilities.availableBatteryStates.contains(batteryState) {
            batteryState = firstSupportedBatteryState
        }

        wifiBars = min(max(wifiBars, capabilities.wifiBarsRange.lowerBound), capabilities.wifiBarsRange.upperBound)
        cellularBars = min(max(cellularBars, capabilities.cellularBarsRange.lowerBound), capabilities.cellularBarsRange.upperBound)
        batteryLevel = min(max(batteryLevel, capabilities.batteryLevelRange.lowerBound), capabilities.batteryLevelRange.upperBound)
    }
}
