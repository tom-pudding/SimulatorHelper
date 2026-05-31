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

    private let environmentService: EnvironmentService
    private let simulatorInventoryService: SimulatorInventoryService

    init(
        environmentService: EnvironmentService = EnvironmentService(),
        simulatorInventoryService: SimulatorInventoryService = SimulatorInventoryService()
    ) {
        self.environmentService = environmentService
        self.simulatorInventoryService = simulatorInventoryService
    }

    func loadInitialData() async {
        await loadEnvironmentIfNeeded()
        await loadSimulatorsIfNeeded()
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
