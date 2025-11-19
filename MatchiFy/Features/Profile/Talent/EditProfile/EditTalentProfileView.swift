import SwiftUI

struct EditTalentProfileView: View {
    
    @StateObject private var vm = EditTalentProfileViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var showImagePicker = false
    
    var body: some View {
        Form {
            
            // MARK: - Avatar
            Section {
                HStack {
                    Spacer()
                    
                    ZStack(alignment: .bottomTrailing) {
                        // Avatar preview
                        if let img = vm.selectedImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 110, height: 110)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 3))
                        } else if let user = AuthManager.shared.user,
                                  let profileImage = user.profileImage,
                                  !profileImage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                                  let url = user.profileImageURL {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image): 
                                    image
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
                            .frame(width: 110, height: 110)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 3))
                        } else {
                            Image("avatar")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 110, height: 110)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 3))
                        }
                        
                        Button {
                            showImagePicker = true
                        } label: {
                            Image(systemName: "camera.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.blue)
                                .background(Color.white.clipShape(Circle()))
                        }
                        .offset(x: 6, y: 6)
                    }
                    
                    Spacer()
                }
            }
            
            // MARK: - Personal Info
            Section(header: Text("Personal Info")) {
                
                TextField("Full Name", text: $vm.name)
                
                TextField("Email", text: $vm.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                
                TextField("Phone", text: $vm.phone)
                    .keyboardType(.phonePad)
                
                TextField("Location", text: $vm.location)
            }
            
            // MARK: - Talents
            Section(header: Text("Talents")) {
                // Add talent input
                HStack {
                    TextField("Add a talent (e.g., Developer, Photographer)", text: $vm.talentInput)
                        .onSubmit {
                            vm.addTalent()
                        }
                    
                    Button {
                        vm.addTalent()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 24))
                    }
                    .disabled(vm.talentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                
                // Talents list
                if !vm.talents.isEmpty {
                    ForEach(vm.talents, id: \.self) { talent in
                        HStack {
                            Text(talent)
                            Spacer()
                            Button {
                                vm.removeTalent(talent)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            
            // MARK: - Skills
            Section(header: Text("Skills")) {
                if vm.isLoadingSkills {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else {
                    SkillPickerView(selectedSkills: $vm.selectedSkills)
                }
            }
            
            // MARK: - Description
            Section(header: Text("Description")) {
                TextField("Description", text: $vm.description, axis: .vertical)
                    .lineLimit(3...6)
            }
            
            // MARK: - Portfolio
            Section(header: Text("Portfolio")) {
                TextField("Portfolio Link", text: $vm.portfolioLink)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .placeholder(when: vm.portfolioLink.isEmpty) {
                        Text("https://your-portfolio.com")
                            .foregroundColor(.gray.opacity(0.6))
                    }
            }
            
            // MARK: - Error
            if let error = vm.errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
            }
            
            // MARK: - Save Button
            Section {
                Button {
                    vm.updateProfile()
                } label: {
                    if vm.isSaving {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        Text("Save Changes")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: vm.saveSuccess) { oldValue, newValue in
            if newValue { dismiss() }
        }
        .sheet(isPresented: $showImagePicker) {
            // Use the shared ImagePicker from Recruiter
            ImagePicker(image: $vm.selectedImage)
        }
    }
}

// MARK: - Placeholder Extension
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct EditTalentProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EditTalentProfileView()
        }
    }
}

