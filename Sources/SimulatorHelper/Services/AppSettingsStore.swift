import Foundation

@MainActor
struct AppSettingsStore {
    private let userDefaults: UserDefaults
    private let screenshotFolderKey = "screenshotFolderPath"

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

    func defaultScreenshotFolder() -> URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Desktop", isDirectory: true)
            .appendingPathComponent("Simulator Helper", isDirectory: true)
    }
}
