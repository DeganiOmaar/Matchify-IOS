import Foundation
import Combine

@MainActor
final class MissionDetailsViewModel: ObservableObject {
    @Published private(set) var mission: MissionModel?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    private let missionId: String
    private let service: MissionService
    
    init(
        missionId: String,
        initialMission: MissionModel? = nil,
        service: MissionService = .shared
    ) {
        self.missionId = missionId
        self.service = service
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
}


