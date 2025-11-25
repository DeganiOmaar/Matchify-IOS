import SwiftUI
import UniformTypeIdentifiers

struct CvDocumentPicker: UIViewControllerRepresentable {
    @Binding var documentURL: URL?
    @Environment(\.presentationMode) private var presentationMode
    
    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: CvDocumentPicker
        
        init(parent: CvDocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            // Start accessing security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                print("❌ Failed to access security-scoped resource")
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            // Copy file to temporary location
            let fileManager = FileManager.default
            let tempDir = fileManager.temporaryDirectory
            let tempURL = tempDir.appendingPathComponent(url.lastPathComponent)
            
            do {
                // Remove existing file if it exists
                if fileManager.fileExists(atPath: tempURL.path) {
                    try fileManager.removeItem(at: tempURL)
                }
                
                // Copy file
                try fileManager.copyItem(at: url, to: tempURL)
                parent.documentURL = tempURL
            } catch {
                print("❌ Error copying file: \(error.localizedDescription)")
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // Define allowed document types: PDF, DOC, DOCX
        var allowedTypes: [UTType] = [.pdf]
        
        // Add DOC type
        if let docType = UTType(filenameExtension: "doc") {
            allowedTypes.append(docType)
        }
        
        // Add DOCX type
        if let docxType = UTType(filenameExtension: "docx") {
            allowedTypes.append(docxType)
        }
        
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedTypes, asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}

