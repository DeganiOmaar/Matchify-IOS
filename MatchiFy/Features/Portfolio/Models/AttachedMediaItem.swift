import Foundation
import UIKit

enum AttachedMediaItem: Identifiable {
    case image(UIImage)
    case video(URL)
    case pdf(URL)
    case externalLink(url: String, title: String)
    case existing(MediaItemModel)
    
    var id: String {
        switch self {
        case .image:
            return UUID().uuidString
        case .video(let url):
            return url.absoluteString
        case .pdf(let url):
            return url.absoluteString
        case .externalLink(let url, _):
            return url
        case .existing(let item):
            return item.id
        }
    }
    
    var displayTitle: String {
        switch self {
        case .image:
            return "Image"
        case .video:
            return "Video"
        case .pdf:
            return "PDF"
        case .externalLink(_, let title):
            return title
        case .existing(let item):
            return item.title ?? item.type.capitalized
        }
    }
}

