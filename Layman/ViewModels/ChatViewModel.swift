//
//  ChatViewModel.swift
//  Layman
//
//  Created by Pawan Priyatham  on 03/04/26.
//

import Foundation
import Combine

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
}

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var suggestions: [String] = []
    @Published var isLoading = false
    @Published var inputText = ""
    
    var articleContext: String = ""
    
    init(article: Article) {
        articleContext = """
        Title: \(article.title)
        Description: \(article.description ?? "")
        Source: \(article.sourceName ?? "")
        """
        messages.append(ChatMessage(
            content: "Hi, I'm Layman! What can I answer for you?",
            isUser: false
        ))
        Task {
            await loadSuggestions()
        }
    }
    
    func loadSuggestions() async {
        do {
            suggestions = try await GroqService.shared.generateSuggestions(
                articleContext: articleContext
            )
        } catch {
            suggestions = ["What happened here?", "Why does this matter?", "Who is involved?"]
        }
    }
    
    func sendMessage(_ text: String) async {
        guard !text.isEmpty else { return }
        inputText = ""
        messages.append(ChatMessage(content: text, isUser: true))
        isLoading = true
        do {
            let reply = try await GroqService.shared.sendMessage(
                userMessage: text,
                articleContext: articleContext
            )
            messages.append(ChatMessage(content: reply, isUser: false))
        } catch {
            messages.append(ChatMessage(
                content: "Sorry, I couldn't answer that right now.",
                isUser: false
            ))
        }
        isLoading = false
    }
}
