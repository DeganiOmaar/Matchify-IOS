import Foundation

struct ProjectsResponse: Codable {
    let message: String
    let projects: [ProjectModel]
}

