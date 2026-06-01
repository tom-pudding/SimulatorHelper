import Foundation

struct StatusBarConfiguration: Equatable, Sendable {
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

    enum BatteryStateOption: String, Sendable {
        case charged
        case discharging
    }

    var timeOverrideMode: TimeOverrideMode
    var dateAndTimeOverride: Date
    var batteryLevel: Int

    static var defaultMVP: StatusBarConfiguration {
        StatusBarConfiguration(
            timeOverrideMode: .timeOnly,
            dateAndTimeOverride: defaultDateAndTimeOverride(),
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
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dateAndTimeOverride)
        let year = components.year ?? 1970
        let month = components.month ?? 1
        let day = components.day ?? 1
        let hour = components.hour ?? 9
        let minute = components.minute ?? 41

        switch timeOverrideMode {
        case .timeOnly:
            return String(format: "%d:%02d", hour, minute)
        case .dateAndTime:
            return String(format: "%04d-%02d-%02dT%02d:%02d:%02d", year, month, day, hour, minute, 0)
        }
    }

    var resolvedBatteryState: BatteryStateOption {
        batteryLevel == 100 ? .charged : .discharging
    }

    mutating func resetTimeToDefault(calendar: Calendar = .current) {
        var components = calendar.dateComponents([.year, .month, .day], from: dateAndTimeOverride)
        components.hour = 9
        components.minute = 41
        components.second = 0
        dateAndTimeOverride = calendar.date(from: components) ?? dateAndTimeOverride
    }

    mutating func normalize(using capabilities: StatusBarCapabilities) {
        batteryLevel = min(max(batteryLevel, capabilities.batteryLevelRange.lowerBound), capabilities.batteryLevelRange.upperBound)
    }
}
