import SwiftUI

struct RecruiterProfileView: View {
    
    @StateObject private var vm = RecruiterProfileViewModel()
    @State private var showMoreSheet = false
    @State private var showEditProfile = false
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: - Banner Image
                    Image("banner")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .clipped()
                        .ignoresSafeArea(edges: .top)
                    
                    // MARK: - Avatar (local or remote)
                    avatarView
                        .offset(y: -60)
                        .padding(.bottom, -60)
                    
                    // MARK: - Name
                    Text(vm.user?.fullName ?? "Recruiter Name")
                        .font(.system(size: 26, weight: .bold))
                    
                    // MARK: - Email
                    Text(vm.user?.email ?? "-")
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .font(.system(size: 16))
                        .padding(.top, 10)
                    
                    // MARK: - Description (Dynamic)
                    VStack {
                        Text(
                            vm.user?.description?.isEmpty == false
                            ? (vm.user?.description ?? "")
                            : "You can add a description about your self."
                        )
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.Colors.cardBackground)
                    .cornerRadius(20)
                    .shadow(color: AppTheme.Colors.cardShadow, radius: 8, x: 0, y: 3)
                    .padding(.horizontal, 20)
                    
                    // MARK: - Information Section
                    informationSection
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
                .padding(.top, 10)
            }
            .background(AppTheme.Colors.groupedBackground)
            .ignoresSafeArea(edges: .top)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showMoreSheet = true
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(AppTheme.Colors.primary)
                            .font(.system(size: 18, weight: .medium))
                    }
                }
            }
            .sheet(isPresented: $showMoreSheet) { moreSheet }
            .navigationDestination(isPresented: $showEditProfile) {
                EditRecruiterProfileView()
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
    
    // MARK: - Avatar View
    private var avatarView: some View {
        Group {
            // Check if profileImage exists and is not empty, then try to get URL
            if let profileImage = vm.user?.profileImage,
               !profileImage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               let url = vm.user?.profileImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Image("avatar")
                            .resizable()
                            .scaledToFill()
                    case .empty:
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
        .frame(width: 120, height: 120)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 4))
    }
    
    
    // MARK: - More sheet
    private var moreSheet: some View {
        NavigationStack {
            List {
                Button {
                    showMoreSheet = false
                    showEditProfile = true
                } label: {
                    Label("Edit Profile", systemImage: "pencil")
                }
                
                Button {
                    showMoreSheet = false
                    showSettings = true
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.height(180), .medium])
    }
}

struct RecruiterProfileView_Previews: PreviewProvider {
    static var previews: some View {
        RecruiterProfileView()
    }
}

// MARK: - Information Section
private extension RecruiterProfileView {
    var informationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Information")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            infoRow(title: "Email", value: vm.user?.email ?? "-")
            
            if let phone = vm.user?.phone, !phone.isEmpty {
                infoRow(title: "Phone", value: phone)
            }
            
            if let location = vm.user?.location, !location.isEmpty {
                infoRow(title: "Location", value: location)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(20)
        .shadow(color: AppTheme.Colors.cardShadow, radius: 8, x: 0, y: 3)
    }
    
    func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.Colors.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.trailing)
        }
    }
}
