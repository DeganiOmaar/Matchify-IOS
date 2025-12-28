import SwiftUI
import UniformTypeIdentifiers

struct DeliverableInputSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ConversationViewModel
    
    @State private var selectedTab = 0
    @State private var linkUrl: String = ""
    @State private var linkTitle: String = ""
    @State private var selectedFileUrl: URL?
    @State private var showFileImporter = false
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Tab Selection
                Picker("Type", selection: $selectedTab) {
                    Text("File").tag(0)
                    Text("Link").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if selectedTab == 0 {
                    // File Tab
                    VStack(spacing: 20) {
                        if let url = selectedFileUrl {
                            HStack {
                                Image(systemName: "doc.fill")
                                    .foregroundColor(AppTheme.Colors.primary)
                                Text(url.lastPathComponent)
                                    .lineLimit(1)
                                Spacer()
                                Button {
                                    selectedFileUrl = nil
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(AppTheme.Colors.secondaryBackground)
                            .cornerRadius(12)
                        } else {
                            Button {
                                showFileImporter = true
                            } label: {
                                VStack(spacing: 12) {
                                    Image(systemName: "arrow.up.doc")
                                        .font(.system(size: 32))
                                    Text("Select a file")
                                        .font(.headline)
                                    Text("PDF, Images, ZIP up to 10MB")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                        .foregroundColor(AppTheme.Colors.primary.opacity(0.5))
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                } else {
                    // Link Tab
                    VStack(spacing: 16) {
                        TextField("Link URL (https://...)", text: $linkUrl)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .padding()
                            .background(AppTheme.Colors.secondaryBackground)
                            .cornerRadius(10)
                        
                        TextField("Link Title (Optional)", text: $linkTitle)
                            .padding()
                            .background(AppTheme.Colors.secondaryBackground)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Confirm Button
                Button {
                    submit()
                } label: {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Confirm Work Completion")
                            .bold()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isValid ? AppTheme.Colors.primary : Color.gray.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(!isValid || isSubmitting)
                .padding()
            }
            .navigationTitle("Submit Work")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.item],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        selectedFileUrl = url
                    }
                case .failure(let error):
                    print("File selection error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private var isValid: Bool {
        if selectedTab == 0 {
            return selectedFileUrl != nil
        } else {
            return !linkUrl.isEmpty && (linkUrl.hasPrefix("http://") || linkUrl.hasPrefix("https://"))
        }
    }
    
    private func submit() {
        guard isValid else { return }
        isSubmitting = true
        
        Task {
            if selectedTab == 0, let url = selectedFileUrl {
                // File submission
                guard url.startAccessingSecurityScopedResource() else { return }
                defer { url.stopAccessingSecurityScopedResource() }
                
                do {
                    let data = try Data(contentsOf: url)
                    let fileName = url.lastPathComponent
                    let mimeType = "application/octet-stream" // Ideally detect mime type
                    
                    viewModel.uploadDeliverable(data: data, fileName: fileName, mimeType: mimeType)
                    await MainActor.run {
                        dismiss()
                    }
                } catch {
                    print("Error reading file: \(error)")
                    isSubmitting = false
                }
            } else {
                // Link submission
                viewModel.submitLink(url: linkUrl, title: linkTitle.isEmpty ? nil : linkTitle)
                await MainActor.run {
                    dismiss()
                }
            }
        }
    }
}
