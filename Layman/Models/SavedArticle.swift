//
//  SavedArticle.swift
//  Layman
//
//  Created by Pawan Priyatham  on 03/04/26.
//

import Foundation

struct SavedArticle: Identifiable, Codable {
    let id: Int
    let userId: String
    let articleId: String
    let title: String
    let imageUrl: String?
    let sourceUrl: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case articleId = "article_id"
        case title
        case imageUrl = "image_url"
        case sourceUrl = "source_url"
        case createdAt = "created_at"
    }
}
