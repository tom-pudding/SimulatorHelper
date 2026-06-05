import Foundation

struct StatusBarConfiguration: Codable, Equatable, Sendable {
    enum BatteryStateOption: String, Sendable {
        case charged
        case discharging
    }

    var timeOverride: Date
    var batteryLevel: Int

    static var defaultMVP: StatusBarConfiguration {
        StatusBarConfiguration(
            timeOverride: defaultTimeOverride(),
            batteryLevel: 100
        )
    }

    static func defaultTimeOverride(referenceDate: Date = .now, calendar: Calendar = .current) -> Date {
        var components = calendar.dateComponents([.year, .month, .day], from: referenceDate)
        components.hour = 9
        components.minute = 41
        components.second = 0
        return calendar.date(from: components) ?? referenceDate
    }

    /// Human-readable "H:MM" form shown in the UI.
    var resolvedTimeString: String {
        let components = Calendar.current.dateComponents([.hour, .minute], from: timeOverride)
        let hour = components.hour ?? 9
        let minute = components.minute ?? 41
        return String(format: "%d:%02d", hour, minute)
    }

    /// Time argument passed to `simctl status_bar override --time`.
    ///
    /// iOS 26's simctl rejects time strings whose literal minute field is "00"
    /// (e.g. "11:00") and whose literal hour field is "0" (e.g. "0:30"), reporting
    /// "Invalid, non-ISO date/time string". We sidestep both bugs by expressing the
    /// target time with minute overflow — for example "10:60" normalizes to 11:00 on
    /// the device — so neither the hour nor minute field is ever zero.
    var simctlTimeArgument: String {
        let components = Calendar.current.dateComponents([.hour, .minute], from: timeOverride)
        let hour = components.hour ?? 9
        let minute = components.minute ?? 41
        return Self.simctlTimeArgument(hour: hour, minute: minute)
    }

    static func simctlTimeArgument(hour: Int, minute: Int) -> String {
        // Direct form is safe only when neither field is zero.
        if minute != 0 && hour != 0 {
            return String(format: "%d:%02d", hour, minute)
        }

        // Shift back one hour and add 60 minutes so the literal fields are non-zero
        // while normalizing to the same wall-clock time. If that lands on the broken
        // hour 0 (target hour 0 or 1), shift back two hours and add 120 minutes.
        var baseHour = hour - 1
        var baseMinute = minute + 60
        if baseHour < 1 {
            baseHour = (hour + 22) % 24
            baseMinute = minute + 120
        }
        return "\(baseHour):\(baseMinute)"
    }

    var resolvedBatteryState: BatteryStateOption {
        batteryLevel == 100 ? .charged : .discharging
    }

    mutating func resetTimeToDefault(calendar: Calendar = .current) {
        var components = calendar.dateComponents([.year, .month, .day], from: timeOverride)
        components.hour = 9
        components.minute = 41
        components.second = 0
        timeOverride = calendar.date(from: components) ?? timeOverride
    }

    mutating func normalize(using capabilities: StatusBarCapabilities) {
        batteryLevel = min(max(batteryLevel, capabilities.batteryLevelRange.lowerBound), capabilities.batteryLevelRange.upperBound)
    }
}
