import SwiftUI

struct RecruiterProfileView: View {
    
    @StateObject private var vm = RecruiterProfileViewModel()
    @State private var showMoreSheet = false
    @State private var showEditProfile = false
    
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
                    
                    // MARK: - Avatar (local OU distant)
                    avatarView
                        .offset(y: -60)
                        .padding(.bottom, -60)
                    
                    // MARK: - Name
                    Text(vm.user?.fullName ?? "Recruiter Name")
                        .font(.system(size: 26, weight: .bold))
                    
                    // MARK: - Email
                    Text(vm.user?.email ?? "-")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                    
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
                    
                    // MARK: - Description
                    VStack {
                        Text("CEO System D, Because your satisfaction is everything & Standing out from the rest, and that’s what we want you to be as well.")
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
            .sheet(isPresented: $showMoreSheet) { moreSheet }
            .navigationDestination(isPresented: $showEditProfile) {
                EditRecruiterProfileView()
            }
        }
    }
    
    // MARK: - Avatar View
    private var avatarView: some View {
        Group {
            if let url = vm.user?.profileImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    default:
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
    
    // MARK: - Info Card
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            Text("Information")
                .font(.system(size: 22, weight: .semibold))
            
            infoRow(icon: "envelope",
                    title: "Email",
                    value: vm.user?.email ?? "-")
            
            infoRow(icon: "phone",
                    title: "Phone",
                    value: vm.user?.phone ?? "-")
            
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
                
                Label("Settings", systemImage: "gearshape")
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.height(180), .medium])
    }
}


// MARK: - Components

@ViewBuilder
func infoRow(icon: String, title: String, value: String) -> some View {
    HStack(alignment: .top) {
        
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color.gray.opacity(0.8))
            
            Text(title)
                .font(.system(size: 17))
                .foregroundColor(Color.gray.opacity(0.9))
        }
        .frame(width: 120, alignment: .leading)
        
        Text(value)
            .font(.system(size: 16))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

@ViewBuilder
func profileButton(icon: String, title: String) -> some View {
    HStack(spacing: 6) {
        Image(systemName: icon)
            .font(.system(size: 18))
            .foregroundColor(.black)
        
        Text(title)
            .font(.system(size: 16))
            .foregroundColor(.black)
    }
    .padding(.horizontal, 18)
    .padding(.vertical, 10)
    .background(
        RoundedRectangle(cornerRadius: 14)
            .stroke(Color(.systemGray4), lineWidth: 1)
    )
}

struct RecruiterProfileView_Previews: PreviewProvider {
    static var previews: some View {
        RecruiterProfileView()
    }
}
