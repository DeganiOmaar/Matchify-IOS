import Foundation
import Combine

final class TalentProfileViewModel: ObservableObject {

    @Published var user: UserModel?
    @Published var joinedText: String = ""

    private var cancellables = Set<AnyCancellable>()
    private let service = TalentProfileService.shared

    init(authManager: AuthManager = .shared) {
        // Load from local first
        self.user = authManager.user
        updateJoinedText()

        // Then load from backend
        loadProfile()

        authManager.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] usr in
                self?.user = usr
                self?.updateJoinedText()
            }
            .store(in: &cancellables)
    }

    func loadProfile() {
        Task { @MainActor in
            do {
                let response = try await service.getTalentProfile()
                self.user = response.user
                AuthManager.shared.persistUpdatedUser(response.user)
                updateJoinedText()
            } catch {
                // Silently fail - keep using local data
                print("Failed to load profile from backend: \(error.localizedDescription)")
            }
        }
    }

    private func updateJoinedText() {
        guard let createdAt = user?.createdAt else {
            joinedText = "-"
            return
        }

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = iso.date(from: createdAt) {
            let f = DateFormatter()
            f.locale = Locale(identifier: "en_US")
            f.dateFormat = "dd MMMM, yyyy"
            joinedText = f.string(from: date)
        } else {
            joinedText = "-"
        }
    }
}

