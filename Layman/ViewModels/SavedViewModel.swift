//
//  SavedViewModel.swift
//  Layman
//
//  Created by Pawan Priyatham  on 03/04/26.
//

import Foundation
import Combine

@MainActor
class SavedViewModel: ObservableObject {
    @Published var savedArticles: [SavedArticle] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchQuery = ""
    
    var filteredArticles: [SavedArticle] {
        if searchQuery.isEmpty {
            return savedArticles
        }
        return savedArticles.filter {
            $0.title.lowercased().contains(searchQuery.lowercased())
        }
    }
    
    func fetchSavedArticles() async {
        isLoading = true
        do {
            savedArticles = try await SupabaseService.shared.fetchSavedArticles()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func unsaveArticle(articleId: String) async {
        do {
            try await SupabaseService.shared.unsaveArticle(articleId: articleId)
            savedArticles.removeAll { $0.articleId == articleId }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
