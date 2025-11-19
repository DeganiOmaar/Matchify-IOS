import Foundation

extension MissionModel {
    /// Format time as "Posted X minutes/hours/days ago"
    var timePostedText: String {
        guard let createdAt = createdAt else { return "Posted recently" }
        
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = iso.date(from: createdAt) else {
            return "Posted recently"
        }
        
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        let minutes = Int(timeInterval / 60)
        let hours = Int(timeInterval / 3600)
        let days = Int(timeInterval / 86400)
        
        if minutes < 1 {
            return "Posted just now"
        } else if minutes < 60 {
            return "Posted \(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if hours < 24 {
            return "Posted \(hours) hour\(hours == 1 ? "" : "s") ago"
        } else if days < 7 {
            return "Posted \(days) day\(days == 1 ? "" : "s") ago"
        } else {
            // For older posts, show date
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return "Posted \(formatter.string(from: date))"
        }
    }
}

