import Foundation
import Combine

final class MissionListViewModel: ObservableObject {
    @Published var missions: [MissionModel] = []
    @Published var favoriteMissions: [MissionModel] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingFavorites: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    @Published var selectedTab: MissionTab = .mostRecent
    @Published var showProfileDrawer: Bool = false
    
    enum MissionTab: String, CaseIterable {
        case bestMatches = "Best Matches"
        case mostRecent = "Most Recent"
        case favorites = "Favorites"
    }
    
    private let service: MissionService
    private let favoriteService: FavoriteService
    private let realtimeService: MissionRealtimeService
    private var cancellables = Set<AnyCancellable>()
    
    init(
        service: MissionService? = nil,
        favoriteService: FavoriteService? = nil,
        realtimeService: MissionRealtimeService? = nil
    ) {
        self.service = service ?? MissionService.shared
        self.favoriteService = favoriteService ?? FavoriteService.shared
        self.realtimeService = realtimeService ?? MissionRealtimeService.shared
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
                
                // Load favorites if talent
                if AuthManager.shared.role == "talent" {
                    await loadFavorites()
                }
            } catch {
                self.isLoading = false
                self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
            }
        }
    }
    
    // MARK: - Load Favorites
    @MainActor
    func loadFavorites() async {
        guard AuthManager.shared.role == "talent" else { return }
        isLoadingFavorites = true
        
        do {
            let favorites = try await favoriteService.getFavorites()
            self.favoriteMissions = favorites
            self.isLoadingFavorites = false
        } catch {
            self.isLoadingFavorites = false
            // Silently fail - favorites will remain empty
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
            
            // Load favorites if talent
            if AuthManager.shared.role == "talent" {
                await loadFavorites()
            }
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
        var filtered: [MissionModel]
        
        // Select source based on tab
        switch selectedTab {
        case .favorites:
            filtered = favoriteMissions
        case .bestMatches, .mostRecent:
            filtered = missions
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { mission in
                mission.title.localizedCaseInsensitiveContains(searchText) ||
                mission.description.localizedCaseInsensitiveContains(searchText) ||
                mission.skills.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Sort based on tab
        switch selectedTab {
        case .bestMatches, .favorites:
            // For best matches and favorites, sort by most recent
            return filtered.sorted { mission1, mission2 in
                guard let date1 = parseDate(mission1.createdAt),
                      let date2 = parseDate(mission2.createdAt) else {
                    return false
                }
                return date1 > date2 // Most recent first
            }
        case .mostRecent:
            // Most recent first
            return filtered.sorted { mission1, mission2 in
                guard let date1 = parseDate(mission1.createdAt),
                      let date2 = parseDate(mission2.createdAt) else {
                    return false
                }
                return date1 > date2 // Most recent first
            }
        }
    }
    
    // MARK: - Toggle Favorite
    @MainActor
    func toggleFavorite(_ mission: MissionModel) {
        let wasFavorite = mission.isFavorited
        
        // Optimistic update
        updateMissionFavoriteStatus(missionId: mission.missionId, isFavorite: !wasFavorite)
        
        Task {
            do {
                if wasFavorite {
                    try await favoriteService.removeFavorite(missionId: mission.missionId)
                } else {
                    _ = try await favoriteService.addFavorite(missionId: mission.missionId)
                }
                
                // Reload to get updated status from backend
                Task { @MainActor in
                    await self.refreshMissions()
                    if self.selectedTab == .favorites {
                        await self.loadFavorites()
                    }
                }
            } catch {
                // Revert on error
                await MainActor.run {
                    self.updateMissionFavoriteStatus(missionId: mission.missionId, isFavorite: wasFavorite)
                    self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
                }
            }
        }
    }
    
    func isFavorite(_ mission: MissionModel) -> Bool {
        mission.isFavorited
    }
    
    private func updateMissionFavoriteStatus(missionId: String, isFavorite: Bool) {
        // Update in missions array
        missions = missions.map { mission in
            if mission.missionId == missionId {
                var updated = mission
                // Create a new MissionModel with updated isFavorite
                return MissionModel(
                    id: updated.id,
                    _id: updated._id,
                    title: updated.title,
                    description: updated.description,
                    duration: updated.duration,
                    budget: updated.budget,
                    price: updated.price,
                    skills: updated.skills,
                    recruiterId: updated.recruiterId,
                    ownerId: updated.ownerId,
                    proposalsCount: updated.proposalsCount,
                    interviewingCount: updated.interviewingCount,
                    hasApplied: updated.hasApplied,
                    isFavorite: isFavorite,
                    createdAt: updated.createdAt,
                    updatedAt: updated.updatedAt
                )
            }
            return mission
        }
        
        // Update in favoriteMissions array
        if isFavorite {
            // Add to favorites if not already there
            if let mission = missions.first(where: { $0.missionId == missionId }),
               !favoriteMissions.contains(where: { $0.missionId == missionId }) {
                favoriteMissions.append(mission)
            }
        } else {
            // Remove from favorites
            favoriteMissions.removeAll { $0.missionId == missionId }
        }
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

