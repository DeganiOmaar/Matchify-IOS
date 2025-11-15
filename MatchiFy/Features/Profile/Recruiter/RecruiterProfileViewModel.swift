import Foundation
import Combine

final class RecruiterProfileViewModel: ObservableObject {

    @Published var user: UserModel?
    @Published var joinedText: String = ""

    private var cancellables = Set<AnyCancellable>()

    init(authManager: AuthManager = .shared) {

        self.user = authManager.user
        updateJoinedText()

        authManager.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] usr in
                self?.user = usr
                self?.updateJoinedText()
            }
            .store(in: &cancellables)
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
