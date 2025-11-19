import Foundation
import Combine
import SwiftUI

/// ViewModel pour l'écran Messages
final class MessagesViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var showFilterMenu: Bool = false
    @Published var messages: [MessageModel] = []
    
    // MARK: - Computed Properties
    var hasMessages: Bool {
        !messages.isEmpty
    }
    
    // MARK: - Initializer
    init() {
        // Pour l'instant, pas de messages (empty state)
        messages = []
    }
    
    // MARK: - Filter Actions (pas de logique réelle pour l'instant)
    func filterUnread() {
        // TODO: Implémenter plus tard
        showFilterMenu = false
    }
    
    func filterFavourite() {
        // TODO: Implémenter plus tard
        showFilterMenu = false
    }
    
    func filterMessages() {
        // TODO: Implémenter plus tard
        showFilterMenu = false
    }
}

