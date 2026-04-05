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
    
    struct InsertSavedArticle: Encodable {
        let user_id: UUID
        let article_id: String
        let title: String
        let image_url: String?
        let source_url: String?
    }
    
    func saveArticle(_ article: Article) async throws {
        let session = try await supabase.auth.session
        let userId = session.user.id
        
        let insertData = InsertSavedArticle(
            user_id: userId,
            article_id: article.id,
            title: article.title,
            image_url: article.imageURL,
            source_url: article.sourceURL
        )
        
        print("[SupabaseService] Saving article: \(article.id) for user: \(userId)")
        
        try await supabase
            .from("saved_articles")
            .insert(insertData)
            .execute()
        
        print("[SupabaseService] Article saved successfully")
    }
    
    func unsaveArticle(articleId: String) async throws {
        let session = try await supabase.auth.session
        let userId = session.user.id.uuidString.lowercased()
        
        print("[SupabaseService] Unsaving article: \(articleId) for user: \(userId)")
        
        try await supabase
            .from("saved_articles")
            .delete()
            .eq("article_id", value: articleId)
            .eq("user_id", value: userId)
            .execute()
        
        print("[SupabaseService] Article unsaved successfully")
    }
    
    func fetchSavedArticles() async throws -> [SavedArticle] {
        let session = try await supabase.auth.session
        let userId = session.user.id.uuidString.lowercased()
        
        print("[SupabaseService] Fetching saved articles for user: \(userId)")
        
        let response: [SavedArticle] = try await supabase
            .from("saved_articles")
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        print("[SupabaseService] Fetched \(response.count) saved articles")
        
        return response
    }
    
    func isArticleSaved(articleId: String) async throws -> Bool {
        let session = try await supabase.auth.session
        let userId = session.user.id.uuidString.lowercased()
        
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
