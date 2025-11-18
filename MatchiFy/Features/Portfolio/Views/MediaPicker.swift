import SwiftUI
import PhotosUI
import AVKit

struct MediaPicker: UIViewControllerRepresentable {
    @Binding var selectedMedia: MediaItem?
    @Environment(\.presentationMode) private var presentationMode
    let mediaTypes: [String] // ["public.image", "public.movie"]
    
    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: MediaPicker
        
        init(parent: MediaPicker) {
            self.parent = parent
        }
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            // Check if it's a video
            if let videoURL = info[.mediaURL] as? URL {
                parent.selectedMedia = .video(videoURL)
            } else if let uiImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                parent.selectedMedia = .image(uiImage)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = context.coordinator
        picker.mediaTypes = mediaTypes
        picker.videoQuality = .typeHigh
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

