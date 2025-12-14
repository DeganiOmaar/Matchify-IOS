import Foundation
import SwiftUI

/// Modèle pour un item du menu drawer
struct DrawerMenuItem: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
    let type: MenuItemType
    
    enum MenuItemType {
        case profile
        case myStats
        case createOffer
        case myOffers
        case browseOffers
        case createMission
        case chatBot
        case settings
        case theme
    }
    
    static var recruiterItems: [DrawerMenuItem] {
        [
            DrawerMenuItem(title: "Profile", iconName: "person.fill", type: .profile),
            DrawerMenuItem(title: "Browse Offers", iconName: "square.grid.2x2.fill", type: .browseOffers),
            DrawerMenuItem(title: "Create Mission", iconName: "plus.circle.fill", type: .createMission),
            DrawerMenuItem(title: "Chat Bot", iconName: "message.fill", type: .chatBot),
            DrawerMenuItem(title: "Settings", iconName: "gearshape.fill", type: .settings),
            DrawerMenuItem(title: "Theme", iconName: "paintbrush.fill", type: .theme)
        ]
    }
    
    static var talentItems: [DrawerMenuItem] {
        [
            DrawerMenuItem(title: "Profile", iconName: "person.fill", type: .profile),
            DrawerMenuItem(title: "My stats", iconName: "chart.bar.fill", type: .myStats),
            DrawerMenuItem(title: "Create Offer", iconName: "plus.circle.fill", type: .createOffer),
            DrawerMenuItem(title: "My Offers", iconName: "square.stack.fill", type: .myOffers),
            DrawerMenuItem(title: "Chat Bot", iconName: "message.fill", type: .chatBot),
            DrawerMenuItem(title: "Settings", iconName: "gearshape.fill", type: .settings),
            DrawerMenuItem(title: "Theme", iconName: "paintbrush.fill", type: .theme)
        ]
    }
}

