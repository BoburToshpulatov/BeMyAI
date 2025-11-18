//
//  AIService.swift
//  BeMyAI
//
//  Created by Bobur Toshpulatov on 14/11/25.
//



import Foundation
import UIKit

enum AIServiceError: LocalizedError {
    case encodingError
    case httpError(statusCode: Int, body: String)
    case decodingError(data: Data)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .encodingError: return "Failed to encode image."
        case .httpError(let code, let body): return "HTTP \(code): \(body)"
        case .decodingError: return "Failed to decode response from server."
        case .networkError(let err): return "Network error: \(err.localizedDescription)"
        }
    }
}

class AIService {
    static let shared = AIService()
    

    private let apiKey = "API-KEY"

    func analyzeImage(_ image: UIImage) async throws -> String {
        guard let jpegData = image.jpegData(compressionQuality: 0.6) else {
            throw AIServiceError.encodingError
        }
        let base64 = jpegData.base64EncodedString()
        
       
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": "Give a medium size, clear, user-friendly description of this image. The details are for blind people so take this into account"],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64)"]]
                    ]
                ]
            ],
            "max_tokens": 400
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
       
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check HTTP status
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                let bodyText = String(data: data, encoding: .utf8) ?? "<binary data>"
                throw AIServiceError.httpError(statusCode: http.statusCode, body: bodyText)
            }
            
            // Decode response
            let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            let content = decoded.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return content.isEmpty ? "AI returned empty response." : content
            
        } catch let error as AIServiceError {
            throw error
        } catch {
            throw AIServiceError.networkError(error)
        }
    }
}


struct OpenAIResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}
