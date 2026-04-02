//
//  SupabaseService.swift
//  Layman
//
//  Created by Pawan Priyatham  on 03/04/26.
//

import Foundation
import Supabase

class SupabaseService {
    static let shared = SupabaseService()
    
    func saveArticle(_ article: Article) async throws {
        let userId = try await supabase.auth.session.user.id.uuidString
        
        try await supabase
            .from("saved_articles")
            .insert([
                "user_id": userId,
                "article_id": article.id,
                "title": article.title,
                "image_url": article.imageURL ?? "",
                "source_url": article.sourceURL ?? ""
            ])
            .execute()
    }
    
    func unsaveArticle(articleId: String) async throws {
        let userId = try await supabase.auth.session.user.id.uuidString
        
        try await supabase
            .from("saved_articles")
            .delete()
            .eq("article_id", value: articleId)
            .eq("user_id", value: userId)
            .execute()
    }
    
    func fetchSavedArticles() async throws -> [SavedArticle] {
        let userId = try await supabase.auth.session.user.id.uuidString
        
        let response: [SavedArticle] = try await supabase
            .from("saved_articles")
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response
    }
    
    func isArticleSaved(articleId: String) async throws -> Bool {
        let userId = try await supabase.auth.session.user.id.uuidString
        
        let response: [SavedArticle] = try await supabase
            .from("saved_articles")
            .select()
            .eq("article_id", value: articleId)
            .eq("user_id", value: userId)
            .execute()
            .value
        
        return !response.isEmpty
    }
}
