import SwiftUI
import AVKit

struct AddEditProjectView: View {
    @StateObject private var vm: AddEditProjectViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showMediaPicker = false
    @State private var showMediaTypeSelection = false
    
    init(project: ProjectModel? = nil) {
        _vm = StateObject(wrappedValue: AddEditProjectViewModel(project: project))
    }
    
    var body: some View {
        Form {
            // MARK: - Media Section
            Section(header: Text("Media")) {
                if let media = vm.selectedMedia {
                    mediaPreview(media: media)
                } else if let existingURL = vm.existingMediaURL {
                    existingMediaPreview(url: existingURL, isVideo: vm.existingMediaType == "video")
                } else {
                    Button {
                        showMediaTypeSelection = true
                    } label: {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("Add Image or Video")
                        }
                    }
                }
            }
            
            // MARK: - Project Details
            Section(header: Text("Project Details")) {
                TextField("Title *", text: $vm.title)
                
                TextField("Role (e.g., Lead Developer)", text: $vm.role)
                
                TextField("Description", text: $vm.description, axis: .vertical)
                    .lineLimit(3...6)
            }
            
            // MARK: - Skills
            Section(header: Text("Skills")) {
                HStack {
                    TextField("Add a skill", text: $vm.skillInput)
                        .onSubmit {
                            vm.addSkill()
                        }
                    
                    Button {
                        vm.addSkill()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 24))
                    }
                    .disabled(vm.skillInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                
                if !vm.skills.isEmpty {
                    ForEach(vm.skills, id: \.self) { skill in
                        HStack {
                            Text(skill)
                            Spacer()
                            Button {
                                vm.removeSkill(skill)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
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
                    vm.saveProject()
                } label: {
                    if vm.isSaving {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        Text(vm.projectId != nil ? "Update Project" : "Create Project")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(vm.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isSaving)
            }
        }
        .navigationTitle(vm.projectId != nil ? "Edit Project" : "New Project")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: vm.saveSuccess) { oldValue, newValue in
            if newValue {
                // Refresh portfolio list when returning
                NotificationCenter.default.post(name: NSNotification.Name("PortfolioDidUpdate"), object: nil)
                dismiss()
            }
        }
        .confirmationDialog("Select Media Type", isPresented: $showMediaTypeSelection) {
            Button("Image") {
                showMediaPicker = true
            }
            Button("Video") {
                showMediaPicker = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showMediaPicker) {
            MediaPicker(
                selectedMedia: $vm.selectedMedia,
                mediaTypes: ["public.image", "public.movie"]
            )
        }
    }
    
    @ViewBuilder
    private func mediaPreview(media: MediaItem) -> some View {
        VStack(spacing: 12) {
            switch media {
            case .image(let image):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
            case .video(let url):
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Button {
                vm.selectedMedia = nil
            } label: {
                Text("Remove Media")
                    .foregroundColor(.red)
            }
        }
    }
    
    @ViewBuilder
    private func existingMediaPreview(url: URL, isVideo: Bool) -> some View {
        VStack(spacing: 12) {
            if isVideo {
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure, .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    @unknown default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Text("Current media (select new media to replace)")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

