import SwiftUI

struct TalentProfileView: View {
    
    @StateObject private var vm = TalentProfileViewModel()
    @State private var showMoreSheet = false
    @State private var showEditProfile = false
    @State private var showSettings = false
    @State private var showPortfolio = false
    
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
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                    
                    // MARK: - Talent Categories
                    if let talents = vm.user?.talent, !talents.isEmpty {
                        FlowLayout(spacing: 8) {
                            ForEach(talents, id: \.self) { talent in
                                Text(talent)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
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
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 3)
                    .padding(.horizontal, 20)
                    
                    // MARK: - Skills Card
                    if let skills = vm.user?.skills, !skills.isEmpty {
                        skillsCard(skills: skills)
                            .padding(.horizontal, 20)
                    }
                    
                    // MARK: - Information Card
                    infoCard
                        .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.top, 10)
            }
            .background(Color(.systemGroupedBackground))
            .ignoresSafeArea(edges: .top)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showEditProfile = true
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
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
    
    // MARK: - Skills Card
    private func skillsCard(skills: [String]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Skills")
                .font(.system(size: 22, weight: .semibold))
            
            FlowLayout(spacing: 8) {
                ForEach(skills, id: \.self) { skill in
                    Text(skill)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(16)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 3)
    }
    
    // MARK: - Info Card
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            Text("Information")
                .font(.system(size: 22, weight: .semibold))
            
            infoRow(icon: "envelope",
                    title: "Email",
                    value: vm.user?.email ?? "-")
            
            if let phone = vm.user?.phone, !phone.isEmpty {
                infoRow(icon: "phone",
                        title: "Phone",
                        value: phone)
            }
            
            if let location = vm.user?.location, !location.isEmpty {
                infoRow(icon: "location",
                        title: "Location",
                        value: location)
            }
            
            if let portfolioLink = vm.user?.portfolioLink, !portfolioLink.isEmpty {
                infoRow(icon: "link",
                        title: "Portfolio",
                        value: portfolioLink)
            }
            
            infoRow(icon: "calendar",
                    title: "Joined",
                    value: vm.joinedText)
            
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 3)
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

