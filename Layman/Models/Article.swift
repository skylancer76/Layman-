//
//  Article.swift
//  Layman
//
//  Created by Pawan Priyatham  on 03/04/26.
//

import Foundation

struct Article: Identifiable, Codable {
    let id: String
    let title: String
    let description: String?
    let imageURL: String?
    let sourceURL: String?
    let sourceName: String?
    let publishedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "article_id"
        case title
        case description = "content"
        case imageURL = "image_url"
        case sourceURL = "link"
        case sourceName = "source_id"
        case publishedAt = "pubDate"
    }
}
