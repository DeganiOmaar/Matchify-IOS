import Foundation

/// Server-Sent Events (SSE) client for real-time streaming
/// Handles SSE event parsing and provides an async stream of events
final class SSEClient: NSObject {
    
    // MARK: - Types
    
    struct SSEEvent {
        let data: String
        let event: String?
        let id: String?
        let retry: Int?
    }
    
    enum SSEError: Error {
        case invalidURL
        case connectionFailed
        case unauthorized
        case streamClosed
        case parsingError(String)
    }
    
    // MARK: - Properties
    
    private var urlSession: URLSession?
    private var dataTask: URLSessionDataTask?
    private var continuation: AsyncStream<SSEEvent>.Continuation?
    private var buffer: String = ""
    
    // MARK: - Lifecycle
    
    override init() {
        super.init()
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 300 // 5 minutes
        configuration.timeoutIntervalForResource = 300
        self.urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    deinit {
        cancel()
    }
    
    // MARK: - Public Methods
    
    /// Connect to an SSE endpoint and return an async stream of events
    /// - Parameters:
    ///   - url: The SSE endpoint URL
    ///   - token: Optional authentication token
    /// - Returns: AsyncStream of SSE events
    func connect(url: URL, token: String? = nil) -> AsyncStream<SSEEvent> {
        return AsyncStream { continuation in
            self.continuation = continuation
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
            request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
            
            if let token = token {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            self.dataTask = self.urlSession?.dataTask(with: request)
            self.dataTask?.resume()
            
            continuation.onTermination = { [weak self] _ in
                self?.cancel()
            }
        }
    }
    
    /// Cancel the SSE connection
    func cancel() {
        dataTask?.cancel()
        dataTask = nil
        continuation?.finish()
        continuation = nil
        buffer = ""
    }
    
    // MARK: - Private Methods
    
    private func parseSSEData(_ data: Data) {
        guard let text = String(data: data, encoding: .utf8) else {
            return
        }
        
        buffer += text
        
        // Process complete events (separated by double newline)
        let events = buffer.components(separatedBy: "\n\n")
        
        // Keep the last incomplete event in the buffer
        buffer = events.last ?? ""
        
        // Process complete events
        for eventText in events.dropLast() {
            if eventText.isEmpty { continue }
            
            var eventData: String?
            var eventType: String?
            var eventId: String?
            var retryValue: Int?
            
            let lines = eventText.components(separatedBy: "\n")
            
            for line in lines {
                if line.isEmpty || line.hasPrefix(":") {
                    // Comment or empty line, skip
                    continue
                }
                
                if line.hasPrefix("data:") {
                    let value = String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                    if eventData == nil {
                        eventData = value
                    } else {
                        eventData? += "\n" + value
                    }
                } else if line.hasPrefix("event:") {
                    eventType = String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                } else if line.hasPrefix("id:") {
                    eventId = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                } else if line.hasPrefix("retry:") {
                    let retryString = String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                    retryValue = Int(retryString)
                }
            }
            
            // Emit event if we have data
            if let data = eventData {
                let event = SSEEvent(
                    data: data,
                    event: eventType,
                    id: eventId,
                    retry: retryValue
                )
                continuation?.yield(event)
            }
        }
    }
}

// MARK: - URLSessionDataDelegate

extension SSEClient: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        guard let httpResponse = response as? HTTPURLResponse else {
            continuation?.finish()
            completionHandler(.cancel)
            return
        }
        
        if httpResponse.statusCode == 200 {
            completionHandler(.allow)
        } else if httpResponse.statusCode == 401 {
            continuation?.finish()
            completionHandler(.cancel)
        } else {
            continuation?.finish()
            completionHandler(.cancel)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        parseSSEData(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("SSE connection error: \(error.localizedDescription)")
        }
        continuation?.finish()
    }
}
