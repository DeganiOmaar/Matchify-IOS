import Foundation
import UIKit

enum ProjectMediaItem {
    case image(UIImage)
    case video(URL)
    case pdf(URL)
    case externalLink(url: String, title: String?)
    
    var fileData: Data? {
        switch self {
        case .image(let image):
            return image.jpegData(compressionQuality: 0.85)
        case .video(let url), .pdf(let url):
            return try? Data(contentsOf: url)
        case .externalLink:
            return nil
        }
    }
    
    var filename: String {
        switch self {
        case .image:
            return "portfolio-image-\(UUID().uuidString).jpg"
        case .video(let url):
            let ext = url.pathExtension.lowercased()
            return "portfolio-video-\(UUID().uuidString).\(ext)"
        case .pdf(let url):
            let ext = url.pathExtension.lowercased()
            return "portfolio-pdf-\(UUID().uuidString).\(ext)"
        case .externalLink:
            return ""
        }
    }
    
    var mimeType: String {
        switch self {
        case .image:
            return "image/jpeg"
        case .video(let url):
            let ext = url.pathExtension.lowercased()
            return ext == "mp4" ? "video/mp4" : "video/quicktime"
        case .pdf:
            return "application/pdf"
        case .externalLink:
            return ""
        }
    }
}

