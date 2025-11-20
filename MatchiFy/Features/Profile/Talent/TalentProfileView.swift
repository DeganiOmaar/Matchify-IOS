import SwiftUI

struct TalentProfileView: View {
    
    @StateObject private var vm = TalentProfileViewModel()
    @State private var showMoreSheet = false
    @State private var showEditProfile = false
    @State private var showSettings = false
    @State private var showPortfolio = false
    @State private var selectedProject: ProjectModel? = nil
    @State private var showProjectDetails = false
    
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
                    }
                    
                    // MARK: - Buttons
                    HStack(spacing: 10) {
                        profileButton(icon: "person", title: "Follow")
                        profileButton(icon: "bubble.left", title: "Message")
                        
                        Button {
                            showMoreSheet = true
                        } label: {
                            profileButton(icon: "ellipsis", title: "More")
                        }
                    }
                    .padding(.top, 10)
                    
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
                    .padding(.bottom, 20) // Extra padding for tab bar
                }
                .padding(.top, 10)
            }
            .background(AppTheme.Colors.groupedBackground)
            .ignoresSafeArea(edges: .top)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showEditProfile = true
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                }
            }
            .sheet(isPresented: $showMoreSheet) { moreSheet }
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
                    showSettings = true
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.height(240), .medium])
    }
}

// MARK: - Flow Layout for Skills
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

struct TalentProfileView_Previews: PreviewProvider {
    static var previews: some View {
        TalentProfileView()
    }
}

