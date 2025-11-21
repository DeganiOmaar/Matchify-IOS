import SwiftUI
import AVKit
import UniformTypeIdentifiers

struct AddEditProjectView: View {
    @StateObject private var vm: AddEditProjectViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showMediaPicker = false
    @State private var showPDFPicker = false
    @State private var showAttachmentOptions = false
    @State private var showExternalLinkSheet = false
    @State private var selectedMediaType: String = "public.image"
    
    init(project: ProjectModel? = nil) {
        _vm = StateObject(wrappedValue: AddEditProjectViewModel(project: project))
    }
    
    var body: some View {
        Form {
            // MARK: - Media Section
            Section(header: Text("Attachments")) {
                // List of attached media
                if !vm.attachedMedia.isEmpty {
                    ForEach(vm.attachedMedia) { media in
                        attachedMediaRow(media: media)
                    }
                }
                
                // Add attachment button
                Button {
                    showAttachmentOptions = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        Text("Add Attachment")
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // MARK: - Project Details
            Section(header: Text("Project Details")) {
                TextField("Title *", text: $vm.title)
                
                TextField("Role (e.g., Lead Developer)", text: $vm.role)
                
                TextField("Description", text: $vm.description, axis: .vertical)
                    .lineLimit(3...10)
                
                TextField("Project Link (e.g., GitHub URL)", text: $vm.projectLink)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
            }
            
            // MARK: - Skills
            Section(header: Text("Skills")) {
                if vm.isLoadingSkills {
                    HStack {
                        Spacer()
                        ProgressView()
                        Text("Chargement des skills...")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else {
                    SkillPickerView(selectedSkills: $vm.selectedSkills)
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
                NotificationCenter.default.post(name: NSNotification.Name("PortfolioDidUpdate"), object: nil)
                dismiss()
            }
        }
        .confirmationDialog("Add Attachment", isPresented: $showAttachmentOptions) {
            Button("Image") {
                selectedMediaType = "public.image"
                showMediaPicker = true
            }
            Button("Video") {
                selectedMediaType = "public.movie"
                showMediaPicker = true
            }
            Button("PDF") {
                showPDFPicker = true
            }
            Button("External Link") {
                showExternalLinkSheet = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showMediaPicker) {
            MediaPicker(
                selectedMedia: Binding(
                    get: { nil },
                    set: { newValue in
                        if let media = newValue {
                            switch media {
                            case .image(let image):
                                vm.addMedia(.image(image))
                            case .video(let url):
                                vm.addMedia(.video(url))
                            }
                        }
                    }
                ),
                mediaTypes: [selectedMediaType]
            )
        }
        .sheet(isPresented: $showPDFPicker) {
            DocumentPicker { url in
                vm.addMedia(.pdf(url))
            }
        }
        .sheet(isPresented: $showExternalLinkSheet) {
            ExternalLinkSheet(
                url: $vm.externalLinkInput,
                title: $vm.externalLinkTitle,
                onAdd: {
                    vm.addExternalLink()
                    showExternalLinkSheet = false
                }
            )
        }
    }
    
    @ViewBuilder
    private func attachedMediaRow(media: AttachedMediaItem) -> some View {
        HStack(spacing: 12) {
            // Preview
            Group {
                switch media {
                case .image(let image):
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                case .video(let url):
                    VideoPlayer(player: AVPlayer(url: url))
                case .pdf:
                    Image(systemName: "doc.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 24))
                case .externalLink:
                    Image(systemName: "link")
                        .foregroundColor(.green)
                        .font(.system(size: 24))
                case .existing(let item):
                    if let url = item.mediaURL {
                        if item.isImage {
                            AsyncImage(url: url) { phase in
                                if case .success(let image) = phase {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                }
                            }
                        } else if item.isVideo {
                            VideoPlayer(player: AVPlayer(url: url))
                        } else {
                            Image(systemName: item.isPdf ? "doc.fill" : "link")
                                .foregroundColor(item.isPdf ? .red : .green)
                        }
                    } else {
                        Image(systemName: "link")
                            .foregroundColor(.green)
                    }
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Title
            VStack(alignment: .leading, spacing: 4) {
                Text(media.displayTitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.black)
                
                if case .externalLink(let url, _) = media {
                    Text(url)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Remove button
            Button {
                vm.removeMedia(media)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 20))
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Document Picker for PDF
struct DocumentPicker: UIViewControllerRepresentable {
    let onDocumentPicked: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onDocumentPicked: onDocumentPicked)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onDocumentPicked: (URL) -> Void
        
        init(onDocumentPicked: @escaping (URL) -> Void) {
            self.onDocumentPicked = onDocumentPicked
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            // Copy to app's documents directory for access
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
            
            do {
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                try FileManager.default.copyItem(at: url, to: destinationURL)
                onDocumentPicked(destinationURL)
            } catch {
                print("Error copying PDF: \(error)")
            }
        }
    }
}

// MARK: - External Link Sheet
struct ExternalLinkSheet: View {
    @Binding var url: String
    @Binding var title: String
    let onAdd: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("External Link")) {
                    TextField("URL *", text: $url)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    
                    TextField("Title (optional)", text: $title)
                }
                
                Section {
                    Button {
                        onAdd()
                    } label: {
                        Text("Add Link")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Add External Link")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
