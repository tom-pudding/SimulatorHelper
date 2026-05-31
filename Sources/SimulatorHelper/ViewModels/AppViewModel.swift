import Observation

@MainActor
@Observable
final class AppViewModel {
    var environmentStatus = EnvironmentStatus.empty
    var isLoadingEnvironment = false
    var simulators: [SimulatorDescriptor] = []
    var selectedSimulatorID: SimulatorDescriptor.ID?
    var isLoadingSimulators = false
    var simulatorErrorMessage: String?
    var statusBarCapabilities = StatusBarCapabilities.empty
    var isLoadingStatusBarCapabilities = false
    var statusBarCapabilitiesErrorMessage: String?
    var statusBarConfiguration = StatusBarConfiguration.defaultMVP
    var isPerformingStatusBarAction = false
    var statusBarResultMessage: String?
    var statusBarResultIsError = false

    private let environmentService: EnvironmentService
    private let simulatorInventoryService: SimulatorInventoryService
    private let statusBarCapabilitiesService: StatusBarCapabilitiesService
    private let statusBarCommandService: StatusBarCommandService

    init(
        environmentService: EnvironmentService = EnvironmentService(),
        simulatorInventoryService: SimulatorInventoryService = SimulatorInventoryService(),
        statusBarCapabilitiesService: StatusBarCapabilitiesService = StatusBarCapabilitiesService(),
        statusBarCommandService: StatusBarCommandService = StatusBarCommandService()
    ) {
        self.environmentService = environmentService
        self.simulatorInventoryService = simulatorInventoryService
        self.statusBarCapabilitiesService = statusBarCapabilitiesService
        self.statusBarCommandService = statusBarCommandService
    }

    func loadInitialData() async {
        await loadEnvironmentIfNeeded()
        await loadSimulatorsIfNeeded()
        await loadStatusBarCapabilitiesIfNeeded()
    }

    func loadEnvironmentIfNeeded() async {
        guard !isLoadingEnvironment, environmentStatus == .empty else {
            return
        }

        await loadEnvironment()
    }

    func loadEnvironment() async {
        guard !isLoadingEnvironment else {
            return
        }

        isLoadingEnvironment = true
        defer { isLoadingEnvironment = false }

        environmentStatus = await environmentService.loadStatus()
        statusBarCapabilities = .empty
        statusBarCapabilitiesErrorMessage = nil
        await loadStatusBarCapabilitiesIfNeeded()
    }

    func loadSimulatorsIfNeeded() async {
        guard !isLoadingSimulators, simulators.isEmpty, simulatorErrorMessage == nil else {
            return
        }

        await loadSimulators()
    }

    func loadSimulators() async {
        guard !isLoadingSimulators else {
            return
        }

        isLoadingSimulators = true
        defer { isLoadingSimulators = false }

        do {
            simulators = try await simulatorInventoryService.loadBootedSimulators()
            simulatorErrorMessage = nil
            synchronizeSelection()
        } catch {
            simulators = []
            selectedSimulatorID = nil
            simulatorErrorMessage = error.localizedDescription
        }
    }

    func loadStatusBarCapabilitiesIfNeeded() async {
        guard !isLoadingStatusBarCapabilities,
              statusBarCapabilities == .empty,
              statusBarCapabilitiesErrorMessage == nil else {
            return
        }

        await loadStatusBarCapabilities()
    }

    func loadStatusBarCapabilities() async {
        guard !isLoadingStatusBarCapabilities else {
            return
        }

        isLoadingStatusBarCapabilities = true
        defer { isLoadingStatusBarCapabilities = false }

        do {
            let capabilities = try await statusBarCapabilitiesService.loadCapabilities()
            statusBarCapabilities = capabilities
            statusBarCapabilitiesErrorMessage = capabilities.supportsMVP
                ? nil
                : "The active toolchain does not expose the full MVP status bar surface."
            statusBarConfiguration.normalize(using: capabilities)
        } catch {
            statusBarCapabilities = .empty
            statusBarCapabilitiesErrorMessage = error.localizedDescription
        }
    }

    func applyStatusBarConfiguration() async {
        guard let selectedSimulator else {
            return
        }

        guard !isPerformingStatusBarAction else {
            return
        }

        isPerformingStatusBarAction = true
        defer { isPerformingStatusBarAction = false }

        do {
            try await statusBarCommandService.apply(
                configuration: statusBarConfiguration,
                capabilities: statusBarCapabilities,
                to: selectedSimulator
            )
            statusBarResultMessage = "Applied status bar overrides to \(selectedSimulator.name)."
            statusBarResultIsError = false
        } catch {
            statusBarResultMessage = error.localizedDescription
            statusBarResultIsError = true
        }
    }

    func clearStatusBarConfiguration() async {
        guard let selectedSimulator else {
            return
        }

        guard !isPerformingStatusBarAction else {
            return
        }

        isPerformingStatusBarAction = true
        defer { isPerformingStatusBarAction = false }

        do {
            try await statusBarCommandService.clear(on: selectedSimulator)
            statusBarResultMessage = "Cleared status bar overrides on \(selectedSimulator.name)."
            statusBarResultIsError = false
        } catch {
            statusBarResultMessage = error.localizedDescription
            statusBarResultIsError = true
        }
    }

    var selectedSimulator: SimulatorDescriptor? {
        guard let selectedSimulatorID else {
            return nil
        }

        return simulators.first(where: { $0.id == selectedSimulatorID })
    }

    private func synchronizeSelection() {
        if let selectedSimulatorID, simulators.contains(where: { $0.id == selectedSimulatorID }) {
            return
        }

        selectedSimulatorID = simulators.first?.id
    }
}
