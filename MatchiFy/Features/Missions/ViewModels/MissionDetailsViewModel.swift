import Foundation
import Combine

@MainActor
final class MissionDetailsViewModel: ObservableObject {
    @Published private(set) var mission: MissionModel?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    private let missionId: String
    private let service: MissionService
    private let favoriteService: FavoriteService
    
    init(
        missionId: String,
        initialMission: MissionModel? = nil,
        service: MissionService? = nil,
        favoriteService: FavoriteService? = nil
    ) {
        self.missionId = missionId
        self.service = service ?? MissionService.shared
        self.favoriteService = favoriteService ?? FavoriteService.shared
        self.mission = initialMission
    }
    
    func loadMission() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let response = try await service.getMission(id: missionId)
                await MainActor.run {
                    self.mission = response
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
                    self.isLoading = false
                }
            }
        }
    }
    
    var headerTitle: String {
        "Mission Details"
    }
    
    var missionTitle: String {
        mission?.title ?? "—"
    }
    
    var postedTimeText: String {
        mission?.timePostedText ?? ""
    }
    
    var summaryText: String {
        mission?.description ?? "No description available."
    }
    
    var priceText: String {
        mission?.formattedBudget ?? "--"
    }
    
    var skills: [String] {
        mission?.skills ?? []
    }
    
    var proposalsCountText: String {
        "\(mission?.proposals ?? 0)"
    }
    
    var interviewingCountText: String {
        "\(mission?.interviewing ?? 0)"
    }
    
    var isFavorite: Bool {
        mission?.isFavorited ?? false
    }
    
    func toggleFavorite() {
        guard let mission = mission else { return }
        let wasFavorite = mission.isFavorited
        let newFavoriteStatus = !wasFavorite
        
        // Optimistic update
        updateMissionFavoriteStatus(isFavorite: newFavoriteStatus)
        
        Task {
            do {
                if wasFavorite {
                    try await favoriteService.removeFavorite(missionId: mission.missionId)
                } else {
                    _ = try await favoriteService.addFavorite(missionId: mission.missionId)
                }
                
                // Reload mission to get updated status from backend
                loadMission()
                
                // Notify MissionListView to update if needed
                NotificationCenter.default.post(name: NSNotification.Name("MissionFavoriteDidUpdate"), object: nil, userInfo: ["missionId": mission.missionId, "isFavorite": newFavoriteStatus])
            } catch {
                // Revert on error
                updateMissionFavoriteStatus(isFavorite: wasFavorite)
                errorMessage = ErrorHandler.getErrorMessage(from: error, context: .general)
            }
        }
    }
    
    func updateMissionFavoriteStatus(isFavorite: Bool) {
        guard let currentMission = mission else { return }
        mission = MissionModel(
            id: currentMission.id,
            _id: currentMission._id,
            title: currentMission.title,
            description: currentMission.description,
            duration: currentMission.duration,
            budget: currentMission.budget,
            price: currentMission.price,
            skills: currentMission.skills,
            recruiterId: currentMission.recruiterId,
            ownerId: currentMission.ownerId,
            proposalsCount: currentMission.proposalsCount,
            interviewingCount: currentMission.interviewingCount,
            hasApplied: currentMission.hasApplied,
            isFavorite: isFavorite,
            status: currentMission.status,
            paymentStatus: currentMission.paymentStatus,
            assignedTalentId: currentMission.assignedTalentId,
            completedAt: currentMission.completedAt,
            createdAt: currentMission.createdAt,
            updatedAt: currentMission.updatedAt
        )
    }
}
