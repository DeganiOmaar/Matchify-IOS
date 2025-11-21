import Foundation
import Combine

enum MissionRealtimeEvent {
    case created(MissionModel)
    case updated(MissionModel)
    case deleted(String)
}

nonisolated(unsafe) struct MissionRealtimePayload: Codable {
    let type: String
    let mission: MissionModel?
    let missionId: String?
}

final class MissionRealtimeService: NSObject, URLSessionDataDelegate {
    static let shared = MissionRealtimeService()
    
    private let subject = PassthroughSubject<MissionRealtimeEvent, Never>()
    var publisher: AnyPublisher<MissionRealtimeEvent, Never> {
        subject.eraseToAnyPublisher()
    }
    
    private var session: URLSession?
    private var task: URLSessionDataTask?
    private var buffer = ""
    private var isConnecting = false
    
    func connect() {
        guard task == nil else { return }
        guard let token = AuthManager.shared.token,
              let url = URL(string: Endpoints.missionStream) else { return }
        
        isConnecting = true
        var request = URLRequest(url: url)
        request.addValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Double.infinity
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        task = session?.dataTask(with: request)
        task?.resume()
    }
    
    func disconnect() {
        task?.cancel()
        session?.invalidateAndCancel()
        task = nil
        session = nil
        buffer = ""
        isConnecting = false
    }
    
    private func scheduleReconnect() {
        guard task == nil, AuthManager.shared.isLoggedIn else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.connect()
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let chunk = String(data: data, encoding: .utf8) else { return }
        buffer.append(chunk)
        processBuffer()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        disconnect()
        scheduleReconnect()
    }
    
    private func processBuffer() {
        let parts = buffer.components(separatedBy: "\n\n")
        guard parts.count > 1 else { return }
        
        // keep last incomplete chunk
        buffer = parts.last ?? ""
        
        for part in parts.dropLast() {
            parseEvent(part)
        }
    }
    
    private func parseEvent(_ rawEvent: String) {
        let dataLines = rawEvent
            .split(separator: "\n")
            .filter { $0.hasPrefix("data:") }
            .map { $0.dropFirst(5).trimmingCharacters(in: .whitespaces) }
        
        guard !dataLines.isEmpty else { return }
        let dataString = dataLines.joined()
        guard let data = dataString.data(using: .utf8) else { return }
        
        do {
            let payload = try JSONDecoder().decode(MissionRealtimePayload.self, from: data)
            DispatchQueue.main.async { [weak self] in
                self?.handlePayload(payload)
            }
        } catch {
        }
    }
    
    private func handlePayload(_ payload: MissionRealtimePayload) {
        switch payload.type {
        case "mission_created":
            if let mission = payload.mission {
                subject.send(.created(mission))
            }
        case "mission_updated":
            if let mission = payload.mission {
                subject.send(.updated(mission))
            }
        case "mission_deleted":
            if let missionId = payload.missionId {
                subject.send(.deleted(missionId))
            }
        default:
            break
        }
    }
}

