import SwiftUI

struct EditRecruiterProfileView: View {
    
    @StateObject private var vm = EditRecruiterProfileViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var showImagePicker = false
    
    var body: some View {
        Form {
            
            // MARK: - Avatar
            Section {
                HStack {
                    Spacer()
                    
                    ZStack(alignment: .bottomTrailing) {
                        avatarPreview
                        
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
                
                // MARK: - Description
                TextField("Description", text: $vm.description, axis: .vertical)
                    .lineLimit(3...6)
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
            ImagePicker(image: $vm.selectedImage)
        }
    }
    
    
    // MARK: - Avatar Preview
    private var avatarPreview: some View {
        Group {
            if let img = vm.selectedImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                
            } else if let url = AuthManager.shared.user?.profileImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFill()
                    default:
                        Image("avatar").resizable().scaledToFill()
                    }
                }
            } else {
                Image("avatar")
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: 110, height: 110)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 3))
    }
}

struct EditRecruiterProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EditRecruiterProfileView()
        }
    }
}
