import Foundation

struct StatusBarConfiguration: Equatable, Sendable {
    struct DataNetworkOption: RawRepresentable, Hashable, Identifiable, Sendable {
        let rawValue: String

        init(rawValue: String) {
            self.rawValue = rawValue
        }

        var id: String { rawValue }

        var title: String {
            switch rawValue {
            case "hide":
                return "Hide"
            case "wifi":
                return "Wi-Fi"
            case "3g":
                return "3G"
            case "4g":
                return "4G"
            case "lte":
                return "LTE"
            case "lte-a":
                return "LTE-A"
            case "lte+":
                return "LTE+"
            case "5g":
                return "5G"
            case "5g+":
                return "5G+"
            case "5g-uwb":
                return "5G UWB"
            case "5g-uc":
                return "5G UC"
            default:
                return rawValue
            }
        }

        static let hide = Self(rawValue: "hide")
        static let wifi = Self(rawValue: "wifi")
        static let threeG = Self(rawValue: "3g")
        static let fourG = Self(rawValue: "4g")
        static let lte = Self(rawValue: "lte")
        static let lteAdvanced = Self(rawValue: "lte-a")
        static let ltePlus = Self(rawValue: "lte+")
        static let fiveG = Self(rawValue: "5g")
        static let fiveGPlus = Self(rawValue: "5g+")
        static let fiveGUWB = Self(rawValue: "5g-uwb")
        static let fiveGUC = Self(rawValue: "5g-uc")
    }

    enum TimeOverrideMode: String, CaseIterable, Identifiable, Sendable {
        case timeOnly
        case dateAndTime

        var id: String { rawValue }

        var title: String {
            switch self {
            case .timeOnly:
                return "Time Only"
            case .dateAndTime:
                return "Date + Time"
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

    var timeOverrideMode: TimeOverrideMode
    var timeString: String
    var dateAndTimeOverride: Date
    var dataNetwork: DataNetworkOption
    var wifiMode: WiFiModeOption
    var wifiBars: Int
    var cellularMode: CellularModeOption
    var cellularBars: Int
    var batteryState: BatteryStateOption
    var batteryLevel: Int

    static var defaultMVP: StatusBarConfiguration {
        StatusBarConfiguration(
            timeOverrideMode: .timeOnly,
            timeString: "9:41",
            dateAndTimeOverride: defaultDateAndTimeOverride(),
            dataNetwork: .wifi,
            wifiMode: .active,
            wifiBars: 3,
            cellularMode: .active,
            cellularBars: 4,
            batteryState: .charged,
            batteryLevel: 100
        )
    }

    static func defaultDateAndTimeOverride(referenceDate: Date = .now, calendar: Calendar = .current) -> Date {
        var components = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        components.hour = 9
        components.minute = 41
        components.second = 0
        return calendar.date(from: components) ?? referenceDate
    }

    var resolvedTimeOverrideValue: String {
        switch timeOverrideMode {
        case .timeOnly:
            return timeString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        case .dateAndTime:
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dateAndTimeOverride)
            let year = components.year ?? 1970
            let month = components.month ?? 1
            let day = components.day ?? 1
            let hour = components.hour ?? 9
            let minute = components.minute ?? 41

            return String(format: "%04d-%02d-%02dT%02d:%02d:%02d", year, month, day, hour, minute, 0)
        }
    }

    mutating func normalize(using capabilities: StatusBarCapabilities) {
        if let firstSupportedNetwork = capabilities.availableDataNetworks.first,
           !capabilities.availableDataNetworks.contains(dataNetwork) {
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
