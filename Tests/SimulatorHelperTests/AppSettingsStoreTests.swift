import Foundation
import Testing
@testable import SimulatorHelper

@MainActor
struct AppSettingsStoreTests {
    @Test
    func returnsDefaultFolderWhenNothingHasBeenSaved() {
        let userDefaults = UserDefaults(suiteName: "SimulatorHelper.AppSettingsStoreTests.default")!
        userDefaults.removePersistentDomain(forName: "SimulatorHelper.AppSettingsStoreTests.default")

        let store = AppSettingsStore(userDefaults: userDefaults)
        let folder = store.loadScreenshotFolder()

        #expect(folder.path.hasSuffix("/Desktop/Simulator Helper"))
    }

    @Test
    func savesAndLoadsChosenFolder() {
        let userDefaults = UserDefaults(suiteName: "SimulatorHelper.AppSettingsStoreTests.saved")!
        userDefaults.removePersistentDomain(forName: "SimulatorHelper.AppSettingsStoreTests.saved")

        let store = AppSettingsStore(userDefaults: userDefaults)
        let chosenFolder = URL(fileURLWithPath: "/tmp/SimulatorShots", isDirectory: true)

        store.saveScreenshotFolder(chosenFolder)

        #expect(store.loadScreenshotFolder() == chosenFolder)
    }

    @Test
    func savesAndLoadsStatusBarConfiguration() {
        let userDefaults = UserDefaults(suiteName: "SimulatorHelper.AppSettingsStoreTests.configuration")!
        userDefaults.removePersistentDomain(forName: "SimulatorHelper.AppSettingsStoreTests.configuration")

        let store = AppSettingsStore(userDefaults: userDefaults)
        let configuration = StatusBarConfiguration(
            timeOverride: Calendar(identifier: .gregorian).date(
                from: DateComponents(year: 2026, month: 6, day: 2, hour: 9, minute: 41, second: 0)
            )!,
            batteryLevel: 82
        )

        store.saveStatusBarConfiguration(configuration)

        #expect(store.loadStatusBarConfiguration() == configuration)
    }

    @Test
    func returnsDefaultConfigurationWhenPersistedConfigurationIsInvalid() {
        let suiteName = "SimulatorHelper.AppSettingsStoreTests.invalidConfiguration"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults.set(Data("not-json".utf8), forKey: "statusBarConfiguration")

        let configuration = AppSettingsStore(userDefaults: userDefaults).loadStatusBarConfiguration()

        #expect(configuration.batteryLevel == 100)
        #expect(configuration.resolvedTimeString == "9:41")
    }
}
