//
//  GorqService.swift
//  Layman
//
//  Created by Pawan Priyatham  on 03/04/26.
//

import Foundation

class GroqService {
    static let shared = GroqService()
    private let apiKey = Bundle.main.infoDictionary?["GROQ_API_KEY"] as? String ?? ""
    private let baseURL = "https://api.groq.com/openai/v1/chat/completions"
    
    func sendMessage(userMessage: String, articleContext: String) async throws -> String {
        guard let url = URL(string: baseURL) else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "llama3-8b-8192",
            "max_tokens": 150,
            "messages": [
                [
                    "role": "system",
                    "content": "You are Layman, a friendly news assistant. Answer in 1-2 sentences max, in very simple everyday language. Here is the article context: \(articleContext)"
                ],
                [
                    "role": "user",
                    "content": userMessage
                ]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(GroqResponse.self, from: data)
        return response.choices.first?.message.content ?? "Sorry, I couldn't answer that."
    }
    
    func generateSuggestions(articleContext: String) async throws -> [String] {
        guard let url = URL(string: baseURL) else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "llama3-8b-8192",
            "max_tokens": 150,
            "messages": [
                [
                    "role": "system",
                    "content": "Generate exactly 3 short curious questions a reader might ask about this article. Return only a JSON array of 3 strings. No extra text."
                ],
                [
                    "role": "user",
                    "content": articleContext
                ]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(GroqResponse.self, from: data)
        
        let content = response.choices.first?.message.content ?? "[]"
        let cleaned = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let jsonData = cleaned.data(using: .utf8),
           let suggestions = try? JSONDecoder().decode([String].self, from: jsonData) {
            return suggestions
        }
        
        return ["What happened here?", "Why does this matter?", "Who is involved?"]
    }
}

struct GroqResponse: Codable {
    let choices: [GroqChoice]
}

struct GroqChoice: Codable {
    let message: GroqMessage
}

struct GroqMessage: Codable {
    let content: String
}
