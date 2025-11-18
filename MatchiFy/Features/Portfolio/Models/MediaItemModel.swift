import Foundation

struct MediaItemModel: Codable, Identifiable {
    let type: String // 'image', 'video', 'pdf', 'external_link'
    let url: String?
    let title: String?
    let externalLink: String?
    
    init(type: String, url: String? = nil, title: String? = nil, externalLink: String? = nil) {
        self.type = type
        self.url = url
        self.title = title
        self.externalLink = externalLink
    }
    
    var id: String {
        return url ?? externalLink ?? UUID().uuidString
    }
    
    var mediaURL: URL? {
        if type == "external_link", let link = externalLink {
            return URL(string: link)
        }
        
        guard var path = url?.trimmingCharacters(in: .whitespacesAndNewlines),
              !path.isEmpty else {
            return nil
        }
        
        if !path.hasPrefix("/") {
            path = "/" + path
        }
        let fullUrlString = Endpoints.baseURL + path
        return URL(string: fullUrlString)
    }
    
    var isImage: Bool {
        return type == "image"
    }
    
    var isVideo: Bool {
        return type == "video"
    }
    
    var isPdf: Bool {
        return type == "pdf"
    }
    
    var isExternalLink: Bool {
        return type == "external_link"
    }
}

