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
}
