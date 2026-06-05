import Foundation

@MainActor
struct AppSettingsStore {
    private let userDefaults: UserDefaults
    private let screenshotFolderKey = "screenshotFolderPath"
    private let statusBarConfigurationKey = "statusBarConfiguration"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadScreenshotFolder() -> URL {
        if let storedPath = userDefaults.string(forKey: screenshotFolderKey), !storedPath.isEmpty {
            return URL(fileURLWithPath: storedPath, isDirectory: true)
        }

        return defaultScreenshotFolder()
    }

    func saveScreenshotFolder(_ url: URL) {
        userDefaults.set(url.path, forKey: screenshotFolderKey)
    }

    func loadStatusBarConfiguration() -> StatusBarConfiguration {
        guard let data = userDefaults.data(forKey: statusBarConfigurationKey) else {
            return .defaultMVP
        }

        do {
            return try JSONDecoder().decode(StatusBarConfiguration.self, from: data)
        } catch {
            return .defaultMVP
        }
    }

    func saveStatusBarConfiguration(_ configuration: StatusBarConfiguration) {
        guard let data = try? JSONEncoder().encode(configuration) else {
            return
        }

        userDefaults.set(data, forKey: statusBarConfigurationKey)
    }

    func defaultScreenshotFolder() -> URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Desktop", isDirectory: true)
            .appendingPathComponent("Simulator Helper", isDirectory: true)
    }
}
