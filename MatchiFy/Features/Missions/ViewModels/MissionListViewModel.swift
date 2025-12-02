import Foundation
import Combine

final class MissionListViewModel: ObservableObject {
    @Published var missions: [MissionModel] = []
    @Published var bestMatchMissions: [BestMatchMissionModel] = []
    @Published var favoriteMissions: [MissionModel] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingBestMatches: Bool = false
    @Published var isLoadingFavorites: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    @Published var selectedTab: MissionTab = .mostRecent
    @Published var showProfileDrawer: Bool = false
    
    enum MissionTab: String, CaseIterable {
        case bestMatches = "Best Match"
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
        observeFavoriteUpdates()
        observeProfileAnalysisRefresh()
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
                
                // Load favorites and best matches if talent
                if AuthManager.shared.role == "talent" {
                    await loadFavorites()
                    await loadBestMatches()
                }
            } catch {
                self.isLoading = false
                self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
            }
        }
    }
    
    // MARK: - Load Best Matches
    @MainActor
    func loadBestMatches() async {
        guard AuthManager.shared.role == "talent" else { return }
        isLoadingBestMatches = true
        errorMessage = nil
        
        do {
            let response = try await service.getBestMatchMissions()
            self.bestMatchMissions = response.missions
            
            // Enrich best matches with full mission data from missions array
            for (index, bestMatch) in self.bestMatchMissions.enumerated() {
                if let fullMission = missions.first(where: { $0.missionId == bestMatch.missionId }) {
                    // Update the mission in missions array to include best match info
                    // This ensures filteredMissions can access the full data
                }
            }
            
            // If no best matches found, check if it's because profile analysis is missing
            if self.bestMatchMissions.isEmpty {
                // Check if we have missions available (if yes, it means profile analysis might be missing)
                if !self.missions.isEmpty {
                    print("⚠️ Best Match: No matches found but missions exist. Profile analysis may be needed.")
                } else {
                    print("⚠️ Best Match: No missions available in the system.")
                }
            }
            
            self.isLoadingBestMatches = false
        } catch {
            self.isLoadingBestMatches = false
            // Log error but don't show it to user unless it's a critical error
            print("⚠️ Failed to load best matches: \(error.localizedDescription)")
            
            // Only set error message if it's not a "no profile analysis" case
            if let apiError = error as? ApiError {
                switch apiError {
                case .server(let message):
                    if !message.contains("profile analysis") && !message.contains("No profile analysis") {
                        self.errorMessage = "Unable to load best matches. Please try again later."
                    }
                default:
                    break
                }
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
            
            // Also update the missions array to sync favorite status
            // This ensures that missions in the main list reflect the correct favorite status
            for favorite in favorites {
                if let index = missions.firstIndex(where: { $0.missionId == favorite.missionId }) {
                    // Update the mission in missions array to have isFavorite: true
                    let existingMission = missions[index]
                    if !existingMission.isFavorited {
                        missions[index] = MissionModel(
                            id: existingMission.id,
                            _id: existingMission._id,
                            title: existingMission.title,
                            description: existingMission.description,
                            duration: existingMission.duration,
                            budget: existingMission.budget,
                            price: existingMission.price,
                            skills: existingMission.skills,
                            recruiterId: existingMission.recruiterId,
                            ownerId: existingMission.ownerId,
                            proposalsCount: existingMission.proposalsCount,
                            interviewingCount: existingMission.interviewingCount,
                            hasApplied: existingMission.hasApplied,
                            isFavorite: true,
                            status: existingMission.status,
                            createdAt: existingMission.createdAt,
                            updatedAt: existingMission.updatedAt
                        )
                    }
                }
            }
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
            
            // Load favorites and best matches if talent
            if AuthManager.shared.role == "talent" {
                await loadFavorites()
                await loadBestMatches()
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
        case .bestMatches:
            // Enrich best matches with full mission data
            filtered = bestMatchMissions.compactMap { bestMatch in
                // Try to find full mission data from missions array
                if let fullMission = missions.first(where: { $0.missionId == bestMatch.missionId }) {
                    return fullMission
                }
                // Fallback: create a minimal MissionModel from best match data
                return bestMatch.toMissionModel()
            }
        case .mostRecent:
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
        case .bestMatches:
            // Sort by matchScore descending
            return filtered.sorted { mission1, mission2 in
                let score1 = bestMatchMissions.first(where: { $0.missionId == mission1.missionId })?.matchScore ?? 0
                let score2 = bestMatchMissions.first(where: { $0.missionId == mission2.missionId })?.matchScore ?? 0
                return score1 > score2
            }
        case .favorites:
            // For favorites, sort by most recent
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
    
    // MARK: - Get Best Match Info
    func getBestMatchInfo(for missionId: String) -> (matchScore: Int, reasoning: String)? {
        guard let bestMatch = bestMatchMissions.first(where: { $0.missionId == missionId }) else {
            return nil
        }
        return (bestMatch.matchScore, bestMatch.reasoning)
    }
    
    // MARK: - Toggle Favorite
    @MainActor
    func toggleFavorite(_ mission: MissionModel) {
        let wasFavorite = mission.isFavorited
        let newFavoriteStatus = !wasFavorite
        
        // Optimistic update - this will trigger UI update immediately
        updateMissionFavoriteStatus(missionId: mission.missionId, isFavorite: newFavoriteStatus)
        
        Task {
            do {
                if wasFavorite {
                    try await favoriteService.removeFavorite(missionId: mission.missionId)
                } else {
                    _ = try await favoriteService.addFavorite(missionId: mission.missionId)
                }
                
                // Notify other views (like MissionDetailsView) about the update
                NotificationCenter.default.post(
                    name: NSNotification.Name("MissionFavoriteDidUpdate"),
                    object: nil,
                    userInfo: ["missionId": mission.missionId, "isFavorite": newFavoriteStatus]
                )
                
                // Only reload favorites list if we're on the favorites tab
                // The missions array is already updated optimistically
                if self.selectedTab == .favorites {
                    await self.loadFavorites()
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
        let missionId = mission.missionId
        
        // Check in missions array first (most up-to-date)
        if let updatedMission = missions.first(where: { $0.missionId == missionId }) {
            return updatedMission.isFavorited
        }
        
        // Check in favoriteMissions array - if it's there, it should be favorite
        // But also check its isFavorite property to be sure
        if let favoriteMission = favoriteMissions.first(where: { $0.missionId == missionId }) {
            return favoriteMission.isFavorited
        }
        
        // Last resort: use the mission's own property
        return mission.isFavorited
    }
    
    private func updateMissionFavoriteStatus(missionId: String, isFavorite: Bool) {
        // First, get the updated mission from missions array (or create it if not found)
        var updatedMission: MissionModel?
        
        // Update in missions array
        missions = missions.map { mission in
            if mission.missionId == missionId {
                // Create a new MissionModel with updated isFavorite
                let updated = MissionModel(
                    id: mission.id,
                    _id: mission._id,
                    title: mission.title,
                    description: mission.description,
                    duration: mission.duration,
                    budget: mission.budget,
                    price: mission.price,
                    skills: mission.skills,
                    recruiterId: mission.recruiterId,
                    ownerId: mission.ownerId,
                    proposalsCount: mission.proposalsCount,
                    interviewingCount: mission.interviewingCount,
                    hasApplied: mission.hasApplied,
                    isFavorite: isFavorite,
                    status: mission.status,
                    createdAt: mission.createdAt,
                    updatedAt: mission.updatedAt
                )
                updatedMission = updated
                return updated
            }
            return mission
        }
        
        // If mission wasn't in missions array, we need to find it elsewhere or create it
        if updatedMission == nil {
            // Try to find it in favoriteMissions
            if let existingFavorite = favoriteMissions.first(where: { $0.missionId == missionId }) {
                updatedMission = MissionModel(
                    id: existingFavorite.id,
                    _id: existingFavorite._id,
                    title: existingFavorite.title,
                    description: existingFavorite.description,
                    duration: existingFavorite.duration,
                    budget: existingFavorite.budget,
                    price: existingFavorite.price,
                    skills: existingFavorite.skills,
                    recruiterId: existingFavorite.recruiterId,
                    ownerId: existingFavorite.ownerId,
                    proposalsCount: existingFavorite.proposalsCount,
                    interviewingCount: existingFavorite.interviewingCount,
                    hasApplied: existingFavorite.hasApplied,
                    isFavorite: isFavorite,
                    status: existingFavorite.status,
                    createdAt: existingFavorite.createdAt,
                    updatedAt: existingFavorite.updatedAt
                )
            }
        }
        
        // Update in favoriteMissions array
        if isFavorite {
            guard let missionToAdd = updatedMission ?? missions.first(where: { $0.missionId == missionId }) else {
                return
            }
            
            // Remove any existing entry first to avoid duplicates
            favoriteMissions.removeAll { $0.missionId == missionId }
            
            // Add the updated mission with isFavorite: true
            favoriteMissions.append(missionToAdd)
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
    
    private func observeFavoriteUpdates() {
        NotificationCenter.default.publisher(for: NSNotification.Name("MissionFavoriteDidUpdate"))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let self = self,
                      let userInfo = notification.userInfo,
                      let missionId = userInfo["missionId"] as? String,
                      let isFavorite = userInfo["isFavorite"] as? Bool else {
                    return
                }
                // Update the mission's favorite status in our arrays
                self.updateMissionFavoriteStatus(missionId: missionId, isFavorite: isFavorite)
            }
            .store(in: &cancellables)
    }
    
    private func observeProfileAnalysisRefresh() {
        NotificationCenter.default.publisher(for: NSNotification.Name("AIProfileAnalysisDidRefresh"))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                // Refresh best matches when profile analysis is updated
                print("🔄 MissionListViewModel: Profile analysis refreshed, reloading best matches...")
                Task { @MainActor in
                    await self.loadBestMatches()
                }
            }
            .store(in: &cancellables)
    }
}

