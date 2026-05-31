import Observation

@MainActor
@Observable
final class AppViewModel {
    var environmentStatus = EnvironmentStatus.empty
    var isLoadingEnvironment = false

    private let environmentService: EnvironmentService

    init(environmentService: EnvironmentService = EnvironmentService()) {
        self.environmentService = environmentService
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
}
