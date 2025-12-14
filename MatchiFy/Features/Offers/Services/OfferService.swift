import Foundation

final class OfferService {
    static let shared = OfferService()
    
    // MARK: - Get All Offers
    func getAllOffers(category: String? = nil, search: String? = nil) async throws -> [OfferModel] {
        let url = category != nil || search != nil 
            ? Endpoints.offersFiltered(category: category, search: search)
            : Endpoints.offers
        
        return try await ApiClient.shared.get(
            url: url,
            requiresAuth: true
        )
    }
    
    // MARK: - Get Single Offer
    func getOffer(id: String) async throws -> OfferModel {
        return try await ApiClient.shared.get(
            url: Endpoints.offer(id: id),
            requiresAuth: true
        )
    }
    
    // MARK: - Create Offer with Files
    func createOffer(
        category: String,
        title: String,
        keywords: [String],
        price: Int,
        description: String,
        capabilities: [String]?,
        bannerImage: Data,
        galleryImages: [Data]?,
        introductionVideo: Data?
    ) async throws -> OfferModel {
        guard let url = URL(string: Endpoints.offers) else {
            throw ApiError.unknown
        }
        
        guard let token = AuthManager.shared.token else {
            throw ApiError.server("Missing authentication token")
        }
        
        // Create multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add text fields
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"category\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(category)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"title\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(title)\r\n".data(using: .utf8)!)
        
        // Add keywords as array (multiple fields with same name)
        for keyword in keywords {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"keywords[]\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(keyword)\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"price\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(price)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"description\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(description)\r\n".data(using: .utf8)!)
        
        // Add capabilities as array (multiple fields with same name)
        if let capabilities = capabilities, !capabilities.isEmpty {
            for capability in capabilities {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"capabilities[]\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(capability)\r\n".data(using: .utf8)!)
            }
        }
        
        // Add banner image
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"banner\"; filename=\"banner.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(bannerImage)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add gallery images
        if let galleryImages = galleryImages {
            for (index, imageData) in galleryImages.enumerated() {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"gallery\"; filename=\"gallery\(index).jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n".data(using: .utf8)!)
            }
        }
        
        // Add video
        if let videoData = introductionVideo {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"video\"; filename=\"video.mp4\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: video/mp4\r\n\r\n".data(using: .utf8)!)
            body.append(videoData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Handle response
        if let httpResponse = response as? HTTPURLResponse {
            if !(200...299).contains(httpResponse.statusCode) {
                let serverMessage = String(decoding: data, as: UTF8.self)
                throw ApiError.server(serverMessage)
            }
        }
        
        do {
            return try JSONDecoder().decode(OfferModel.self, from: data)
        } catch {
            print("❌ Decoding error: \(error)")
            if let dataString = String(data: data, encoding: .utf8) {
                print("📄 Response data: \(dataString.prefix(500))")
            }
            throw ApiError.decoding
        }
    }
    
    // MARK: - Update Offer
    func updateOffer(
        id: String,
        title: String,
        description: String,
        price: Double,
        keywords: [String],
        capabilities: [String]?
    ) async throws -> OfferModel {
        struct UpdateOfferRequest: Codable {
            let title: String
            let description: String
            let price: Double
            let keywords: [String]
            let capabilities: [String]?
        }
        
        let updateData = UpdateOfferRequest(
            title: title,
            description: description,
            price: price,
            keywords: keywords,
            capabilities: capabilities
        )
        
        return try await ApiClient.shared.put(
            url: Endpoints.offer(id: id),
            body: updateData,
            requiresAuth: true
        )
    }
    
    // MARK: - Delete Offer
    func deleteOffer(id: String) async throws -> OfferModel {
        return try await ApiClient.shared.delete(
            url: Endpoints.offer(id: id),
            requiresAuth: true
        )
    }
}
