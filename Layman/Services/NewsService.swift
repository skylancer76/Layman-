//
//  NewsService.swift
//  Layman
//
//  Created by Pawan Priyatham  on 03/04/26.
//

import Foundation

class NewsService {
    static let shared = NewsService()
    private let apiKey = Bundle.main.infoDictionary?["NEWS_API_KEY"] as? String ?? ""
    private let baseURL = "https://newsdata.io/api/1/news"
    
    func fetchArticles() async throws -> [Article] {
        let urlString = "\(baseURL)?apikey=\(apiKey)&category=business,technology&language=en&size=10"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let response = try JSONDecoder().decode(NewsResponse.self, from: data)
        return response.results ?? []
    }
    
    func searchArticles(query: String) async throws -> [Article] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "\(baseURL)?apikey=\(apiKey)&q=\(encoded)&category=business,technology&language=en"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(NewsResponse.self, from: data)
        return response.results ?? []
    }
}

struct NewsResponse: Codable {
    let status: String?
    let results: [Article]?
}
