import SwiftUI

/// Left-side drawer view avec section utilisateur et menu items
struct ProfileDrawerView: View {
    @StateObject private var drawerViewModel = DrawerViewModel()
    let onItemSelected: (DrawerMenuItem.MenuItemType) -> Void
    
    init(onItemSelected: @escaping (DrawerMenuItem.MenuItemType) -> Void) {
        self.onItemSelected = onItemSelected
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - User Section
            userSection
                .padding(.top, 40)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            
            Divider()
                .background(AppTheme.Colors.border.opacity(0.3))
            
            // MARK: - Menu Items
            menuItemsList
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppTheme.Colors.groupedBackground)
    }
    
    private var isRecruiter: Bool {
        drawerViewModel.user?.role.lowercased() == "recruiter"
    }
    
    private var menuItems: [DrawerMenuItem] {
        isRecruiter ? DrawerMenuItem.recruiterItems : DrawerMenuItem.talentItems
    }
    
    // MARK: - User Section
    private var userSection: some View {
        HStack(alignment: .center, spacing: 16) {
            // Profile Image (left)
            profileImageView
            
            // Name and Talent (right, vertically stacked)
            VStack(alignment: .leading, spacing: 4) {
                // Full Name
                Text(drawerViewModel.fullName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                // Talent (si existe)
                if !isRecruiter, let talent = drawerViewModel.talent {
                    Text(talent)
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Profile Image View
    private var profileImageView: some View {
        Group {
            if drawerViewModel.hasProfileImage,
               let url = drawerViewModel.profileImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img
                            .resizable()
                            .scaledToFill()
                    case .failure, .empty:
                        Image("avatar")
                            .resizable()
                            .scaledToFill()
                    @unknown default:
                        Image("avatar")
                            .resizable()
                            .scaledToFill()
                    }
                }
            } else {
                Image("avatar")
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(AppTheme.Colors.border.opacity(0.2), lineWidth: 2)
        )
    }
    
    // MARK: - Menu Items List
    private var menuItemsList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(menuItems.enumerated()), id: \.element.id) { index, item in
                    menuItemRow(item: item)
                    
                    // Divider entre les groupes (sauf après le dernier item)
                    if index < menuItems.count - 1 {
                        Divider()
                            .background(AppTheme.Colors.border.opacity(0.3))
                            .padding(.leading, 56) // Aligné avec le texte (icon + padding)
                    }
                }
            }
        }
    }
    
    // MARK: - Menu Item Row
    private func menuItemRow(item: DrawerMenuItem) -> some View {
        Button {
            onItemSelected(item.type)
        } label: {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: item.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.Colors.iconPrimary)
                    .frame(width: 24, height: 24)
                
                // Label
                Text(item.title)
                    .font(.system(size: 17))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
    }
}

