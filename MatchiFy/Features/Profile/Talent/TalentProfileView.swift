import SwiftUI

struct TalentProfileView: View {
    
    @StateObject private var vm = TalentProfileViewModel()
    @State private var showMoreSheet = false
    @State private var showEditProfile = false
    @State private var showSettings = false
    @State private var showPortfolio = false
    @State private var selectedProject: ProjectModel? = nil
    @State private var showProjectDetails = false
    @State private var showDocumentPicker = false
    @State private var selectedDocumentURL: URL? = nil
    @State private var isUploadingCV = false
    @State private var uploadError: String? = nil
    
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
                    Text(vm.user?.fullName ?? "Talent Name")
                        .font(.system(size: 26, weight: .bold))
                    
                    // MARK: - Email
                    Text(vm.user?.email ?? "-")
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .font(.system(size: 16))
                    
                    // MARK: - Talent Categories
                    if let talents = vm.user?.talent, !talents.isEmpty {
                        FlowLayout(spacing: 8) {
                            ForEach(talents, id: \.self) { talent in
                                Text(talent)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppTheme.Colors.primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(AppTheme.Colors.primary.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    
                    // MARK: - Description (Dynamic)
                    VStack {
                        Text(
                            vm.user?.description?.isEmpty == false
                            ? (vm.user?.description ?? "")
                            : "You can add a description about yourself."
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
                    
                    // MARK: - Skills Card
                    if !vm.skillNames.isEmpty {
                        skillsCard(skills: vm.skillNames)
                            .padding(.horizontal, 20)
                    }
                    
                    // MARK: - Portfolio Section
                    PortfolioSectionView(
                        projects: vm.projects,
                        onProjectTap: { project in
                            selectedProject = project
                            showProjectDetails = true
                        },
                        onAddProject: {
                            showPortfolio = true
                        }
                    )
                    .padding(.horizontal, 20)
                    
                    // MARK: - CV Section
                    if let cvUrl = vm.user?.cvUrl, !cvUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        cvSection(cvUrl: cvUrl)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 20) // Extra padding for tab bar
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
            .sheet(isPresented: $showDocumentPicker) {
                CvDocumentPicker(documentURL: $selectedDocumentURL)
            }
            .navigationDestination(isPresented: $showEditProfile) {
                EditTalentProfileView()
            }
            .navigationDestination(isPresented: $showPortfolio) {
                PortfolioListView()
            }
            .navigationDestination(isPresented: $showProjectDetails) {
                if let project = selectedProject {
                    ProjectDetailsView(project: project)
                }
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("PortfolioDidUpdate"))) { _ in
                vm.loadProjects()
            }
            .onChange(of: selectedDocumentURL) { newURL in
                if let url = newURL {
                    uploadCV(fileURL: url)
                }
            }
        }
        .alert("Erreur", isPresented: .constant(uploadError != nil)) {
            Button("OK") {
                uploadError = nil
            }
        } message: {
            if let error = uploadError {
                Text(error)
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
    
    // MARK: - Skills Card
    private func skillsCard(skills: [String]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Skills")
                .font(.system(size: 22, weight: .semibold))
            
            FlowLayout(spacing: 8) {
                ForEach(skills, id: \.self) { skill in
                    Text(skill)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.Colors.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.Colors.primary.opacity(0.1))
                        .cornerRadius(16)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(20)
        .shadow(color: AppTheme.Colors.cardShadow, radius: 8, x: 0, y: 3)
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
                    showPortfolio = true
                } label: {
                    Label("Portfolio", systemImage: "folder.fill")
                }
                
                Button {
                    showMoreSheet = false
                    showDocumentPicker = true
                } label: {
                    Label("Attach your CV", systemImage: "doc.fill")
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
        .presentationDetents([.height(300), .medium])
    }
    
    // MARK: - CV Section
    private func cvSection(cvUrl: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CV")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            HStack {
                Image(systemName: "doc.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.Colors.primary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Curriculum Vitae")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    Text("PDF / DOC / DOCX")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                if let url = vm.user?.cvUrlURL {
                    Link(destination: url) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(20)
        .shadow(color: AppTheme.Colors.cardShadow, radius: 8, x: 0, y: 3)
    }
    
    // MARK: - Upload CV
    private func uploadCV(fileURL: URL) {
        isUploadingCV = true
        uploadError = nil
        
        Task { @MainActor in
            do {
                let response = try await TalentProfileService.shared.uploadCV(fileURL: fileURL)
                // Update user in AuthManager
                AuthManager.shared.persistUpdatedUser(response.user)
                // Refresh profile
                vm.loadProfile()
                isUploadingCV = false
                selectedDocumentURL = nil
            } catch {
                isUploadingCV = false
                uploadError = error.localizedDescription
                selectedDocumentURL = nil
            }
        }
    }
}

struct TalentProfileView_Previews: PreviewProvider {
    static var previews: some View {
        TalentProfileView()
    }
}

