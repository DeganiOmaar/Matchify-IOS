import SwiftUI

struct MessagesView: View {
    @StateObject private var viewModel = MessagesViewModel()
    @StateObject private var auth = AuthManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.groupedBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // MARK: - Top Section
                    topSection
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    
                    // MARK: - Search Bar with Filter
                    searchBarSection
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                    
                    // MARK: - Content
                    if viewModel.hasMessages {
                        // TODO: Messages list will be implemented later
                        messagesList
                    } else {
                        emptyStateView
                    }
                }
                
                // MARK: - Overlay to close filter menu when tapping outside
                if viewModel.showFilterMenu {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeIn(duration: 0.15)) {
                                viewModel.showFilterMenu = false
                            }
                        }
                        .zIndex(999)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Top Section
    private var topSection: some View {
        HStack(alignment: .center, spacing: 10) {
            // Profile Image
            profileImageView
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            
            // Title
            Text("Messages")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Spacer()
            
            // Add Message Button
            Button {
                // TODO: Action later
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(AppTheme.Colors.primary)
                    .clipShape(Circle())
            }
        }
    }
    
    // MARK: - Profile Image View
    private var profileImageView: some View {
        Group {
            if let profileImage = auth.user?.profileImage,
               !profileImage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               let url = auth.user?.profileImageURL {
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
    }
    
    // MARK: - Search Bar Section
    private var searchBarSection: some View {
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 12) {
                // Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    TextField(text: $viewModel.searchText) {
                        Text("Search")
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(AppTheme.Colors.inputBackground.opacity(0.8))
                .cornerRadius(12)
                
                // Filter Icon Button
                Button {
                    withAnimation(.easeOut(duration: 0.2)) {
                        viewModel.showFilterMenu.toggle()
                    }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(AppTheme.Colors.iconPrimary)
                        .frame(width: 44, height: 44)
                        .background(AppTheme.Colors.inputBackground)
                        .cornerRadius(12)
                }
            }
            
            // Pop-up positioned below the entire search bar section
            if viewModel.showFilterMenu {
                filterPopUpMenu
                    .offset(x: 0, y: 56) // Positioned below both search bar and filter icon
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.85).combined(with: .opacity).animation(.easeOut(duration: 0.2)),
                        removal: .opacity.animation(.easeIn(duration: 0.15))
                    ))
            }
        }
    }
    
    // MARK: - Filter Pop-up Menu
    private var filterPopUpMenu: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Unread
            filterMenuItem(
                icon: "envelope.badge.fill",
                title: "Unread",
                action: {
                    withAnimation(.easeIn(duration: 0.15)) {
                        viewModel.filterUnread()
                    }
                }
            )
            
            Divider()
                .background(AppTheme.Colors.border.opacity(0.2))
            
            // Favourite
            filterMenuItem(
                icon: "star.fill",
                title: "Favourite",
                action: {
                    withAnimation(.easeIn(duration: 0.15)) {
                        viewModel.filterFavourite()
                    }
                }
            )
            
            Divider()
                .background(AppTheme.Colors.border.opacity(0.2))
            
            // Messages
            filterMenuItem(
                icon: "message.fill",
                title: "Messages",
                action: {
                    withAnimation(.easeIn(duration: 0.15)) {
                        viewModel.filterMessages()
                    }
                }
            )
        }
        .background(
            // More subtle semi-transparent background with blur effect
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 3)
        .frame(width: 180)
        .zIndex(1000)
    }
    
    // MARK: - Filter Menu Item
    private func filterMenuItem(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.iconPrimary)
                    .frame(width: 18, height: 18)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Messages List (placeholder)
    private var messagesList: some View {
        ScrollView {
            VStack(spacing: 0) {
                // TODO: Implement messages list later
                Text("Messages list will be implemented later")
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .padding()
            }
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
                .frame(height: 60)
            
            // Large Illustration
            Image(systemName: "message.fill")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.3))
            
            // Text
            Text("No messages yet!")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            // Button
            Button {
                // TODO: Navigation logic later
            } label: {
                Text("Search for jobs")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.Colors.primary)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MessagesView()
}

