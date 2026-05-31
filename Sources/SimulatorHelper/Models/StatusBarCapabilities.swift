import Foundation

struct StatusBarCapabilities: Equatable, Sendable {
    enum Flag: String, Hashable, Sendable {
        case time
        case dataNetwork
        case wifiMode
        case wifiBars
        case cellularMode
        case cellularBars
        case operatorName
        case batteryState
        case batteryLevel
    }

    var supportedFlags: Set<Flag>
    var supportedDataNetworks: [String]
    var supportedWiFiModes: [String]
    var supportedCellularModes: [String]
    var supportedBatteryStates: [String]
    var wifiBarsRange: ClosedRange<Int>
    var cellularBarsRange: ClosedRange<Int>
    var batteryLevelRange: ClosedRange<Int>

    static let empty = StatusBarCapabilities(
        supportedFlags: [],
        supportedDataNetworks: [],
        supportedWiFiModes: [],
        supportedCellularModes: [],
        supportedBatteryStates: [],
        wifiBarsRange: 0...3,
        cellularBarsRange: 0...4,
        batteryLevelRange: 0...100
    )

    var supportsMVP: Bool {
        let requiredFlags: Set<Flag> = [
            .time,
            .batteryState,
            .batteryLevel,
        ]

        return supportedFlags.isSuperset(of: requiredFlags)
    }
}
