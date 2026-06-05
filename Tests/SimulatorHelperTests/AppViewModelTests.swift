import Foundation
import Testing
@testable import SimulatorHelper

@MainActor
struct AppViewModelTests {
    @Test
    func restoresPersistedStatusBarConfigurationOnInit() {
        let store = makeAppSettingsStore(suiteName: "SimulatorHelper.AppViewModelTests.restore")
        let savedConfiguration = StatusBarConfiguration(
            timeOverride: Calendar(identifier: .gregorian).date(
                from: DateComponents(year: 2026, month: 6, day: 2, hour: 11, minute: 15, second: 0)
            )!,
            batteryLevel: 77
        )
        store.saveStatusBarConfiguration(savedConfiguration)

        let viewModel = AppViewModel(appSettingsStore: store)

        #expect(viewModel.statusBarConfiguration == savedConfiguration)
    }

    @Test
    func editingStatusBarConfigurationPersistsChanges() {
        let store = makeAppSettingsStore(suiteName: "SimulatorHelper.AppViewModelTests.persistEdits")
        let viewModel = AppViewModel(appSettingsStore: store)
        let updatedConfiguration = StatusBarConfiguration(
            timeOverride: Calendar(identifier: .gregorian).date(
                from: DateComponents(year: 2026, month: 6, day: 2, hour: 13, minute: 5, second: 0)
            )!,
            batteryLevel: 64
        )

        viewModel.statusBarConfiguration = updatedConfiguration

        #expect(store.loadStatusBarConfiguration() == updatedConfiguration)
    }

    @Test
    func openingScreenshotFolderReportsSuccess() {
        let folderURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let store = makeAppSettingsStore(suiteName: "SimulatorHelper.AppViewModelTests.openFolderSuccess")
        store.saveScreenshotFolder(folderURL)
        let viewModel = AppViewModel(
            appSettingsStore: store,
            folderOpeningService: FolderOpeningService(openHandler: { _ in true })
        )

        viewModel.openScreenshotFolder()

        #expect(viewModel.screenshotResultIsError == false)
        #expect(viewModel.screenshotResultMessage == "Opened screenshot folder at \(folderURL.path).")
    }

    @Test
    func openingScreenshotFolderReportsFailure() {
        let folderURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let store = makeAppSettingsStore(suiteName: "SimulatorHelper.AppViewModelTests.openFolderFailure")
        store.saveScreenshotFolder(folderURL)
        let viewModel = AppViewModel(
            appSettingsStore: store,
            folderOpeningService: FolderOpeningService(openHandler: { _ in false })
        )

        viewModel.openScreenshotFolder()

        #expect(viewModel.screenshotResultIsError)
        #expect(viewModel.screenshotResultMessage == "Failed to open the screenshot folder at \(folderURL.path).")
    }
}

@MainActor
private func makeAppSettingsStore(suiteName: String) -> AppSettingsStore {
    let userDefaults = UserDefaults(suiteName: suiteName)!
    userDefaults.removePersistentDomain(forName: suiteName)
    return AppSettingsStore(userDefaults: userDefaults)
}

private let sampleIPhoneSimulator = SimulatorDescriptor(
    udid: "38C2AD9E-9318-445C-95CC-AAC69492FC2D",
    name: "iPhone 17 Pro",
    runtimeIdentifier: "com.apple.CoreSimulator.SimRuntime.iOS-26-3",
    runtimeName: "iOS 26.3",
    deviceTypeIdentifier: "com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro",
    productFamily: .iPhone,
    state: "Booted",
    lastBootedAt: ISO8601DateFormatter().date(from: "2026-05-31T12:39:20Z")
)

private let sampleIPadSimulator = SimulatorDescriptor(
    udid: "3FE64A14-8849-430C-87A4-1304F9E9F791",
    name: "iPad Pro 13-inch (M5)",
    runtimeIdentifier: "com.apple.CoreSimulator.SimRuntime.iOS-26-3",
    runtimeName: "iOS 26.3",
    deviceTypeIdentifier: "com.apple.CoreSimulator.SimDeviceType.iPad-Pro-13-inch-M5-12GB",
    productFamily: .iPad,
    state: "Booted",
    lastBootedAt: ISO8601DateFormatter().date(from: "2026-05-31T13:40:00Z")
)
