import Foundation
import Combine

final class MissionListViewModel: ObservableObject {
    @Published var missions: [MissionModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    @Published var selectedTab: MissionTab = .mostRecent
    @Published var favoriteMissions: Set<String> = []
    @Published var showProfileDrawer: Bool = false
    
    enum MissionTab: String, CaseIterable {
        case bestMatches = "Best Matches"
        case mostRecent = "Most Recent"
    }
    
    private let service: MissionService
    private let realtimeService: MissionRealtimeService
    private var cancellables = Set<AnyCancellable>()
    
    init(
        service: MissionService = .shared,
        realtimeService: MissionRealtimeService = .shared
    ) {
        self.service = service
        self.realtimeService = realtimeService
        observeRealtime()
    }
    
    // MARK: - Load Missions
    @MainActor
    func loadMissions() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedMissions = try await service.getAllMissions()
                self.missions = fetchedMissions
                self.isLoading = false
            } catch {
                self.isLoading = false
                self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
            }
        }
    }
    
    // MARK: - Delete Mission
    @MainActor
    func deleteMission(_ mission: MissionModel) {
        Task {
            do {
                _ = try await service.deleteMission(id: mission.missionId)
                // Remove from local array
                missions.removeAll { $0.missionId == mission.missionId }
            } catch {
                errorMessage = ErrorHandler.getErrorMessage(from: error, context: .missionDelete)
            }
        }
    }
    
    // MARK: - Refresh Missions
    @MainActor
    func refreshMissions() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedMissions = try await service.getAllMissions()
            self.missions = fetchedMissions
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
        }
    }
    
    // MARK: - Check if Mission Owner
    func isMissionOwner(_ mission: MissionModel) -> Bool {
        guard let currentUserId = AuthManager.shared.user?.id ?? AuthManager.shared.user?._id else {
            return false
        }
        return mission.ownerIdentifier == currentUserId
    }
    
    // MARK: - Filtered Missions
    var filteredMissions: [MissionModel] {
        var filtered = missions
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { mission in
                mission.title.localizedCaseInsensitiveContains(searchText) ||
                mission.description.localizedCaseInsensitiveContains(searchText) ||
                mission.skills.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // For now, both tabs show the same content (sorted by most recent)
        return filtered.sorted { mission1, mission2 in
            guard let date1 = parseDate(mission1.createdAt),
                  let date2 = parseDate(mission2.createdAt) else {
                return false
            }
            return date1 > date2 // Most recent first
        }
    }
    
    // MARK: - Toggle Favorite
    func toggleFavorite(_ mission: MissionModel) {
        if favoriteMissions.contains(mission.missionId) {
            favoriteMissions.remove(mission.missionId)
        } else {
            favoriteMissions.insert(mission.missionId)
        }
    }
    
    func isFavorite(_ mission: MissionModel) -> Bool {
        favoriteMissions.contains(mission.missionId)
    }
    
    // MARK: - Helper
    private func parseDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return iso.date(from: dateString)
    }
    
    private func observeRealtime() {
        realtimeService.publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .created(let mission):
                    self.missions.removeAll { $0.missionId == mission.missionId }
                    self.missions.insert(mission, at: 0)
                case .updated(let mission):
                    self.missions = self.missions.map { existing in
                        if existing.missionId == mission.missionId {
                            return mission
                        }
                        return existing
                    }
                case .deleted(let missionId):
                    self.missions.removeAll { $0.missionId == missionId }
                }
            }
            .store(in: &cancellables)
        
        realtimeService.connect()
    }
}

