//
//  ArticlesViewModel.swift
//  Layman
//
//  Created by Pawan Priyatham  on 03/04/26.
//

import Foundation
import Combine

@MainActor
class ArticlesViewModel: ObservableObject {
    @Published var featuredArticles: [Article] = []
    @Published var todaysPicks: [Article] = []
    @Published var searchResults: [Article] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchQuery = ""
    
    func fetchArticles() async {
        isLoading = true
        errorMessage = nil
        do {
            let articles = try await NewsService.shared.fetchArticles()
            featuredArticles = Array(articles.prefix(5))
            todaysPicks = Array(articles.dropFirst(5))
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func searchArticles() async {
        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }
        isLoading = true
        do {
            searchResults = try await NewsService.shared.searchArticles(query: searchQuery)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
