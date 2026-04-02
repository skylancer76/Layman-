//
//  ArticleDetailView.swift
//  Layman
//
//  Created by Pawan Priyatham  on 03/04/26.
//

import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @State private var isSaved = false
    @State private var currentCard = 0
    @State private var showWebView = false
    @State private var showChat = false
    @Environment(\.dismiss) var dismiss
    
    let contentCards: [String]
    
    init(article: Article) {
        self.article = article
        // Split description into 3 cards
        let fullText = article.description ?? "No content available for this article."
        let words = fullText.split(separator: " ").map(String.init)
        let chunkSize = max(1, words.count / 3)
        
        var cards: [String] = []
        for i in 0..<3 {
            let start = i * chunkSize
            let end = min(start + chunkSize, words.count)
            if start < words.count {
                cards.append(words[start..<end].joined(separator: " "))
            } else {
                cards.append(fullText)
            }
        }
        self.contentCards = cards
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: "#FFF8F0").ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Headline
                    Text(article.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    
                    // Source + Date
                    HStack {
                        Text(article.sourceName ?? "")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "#F97316"))
                        Spacer()
                        Text(article.publishedAt?.prefix(10) ?? "")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    
                    // Article Image
                    AsyncImage(url: URL(string: article.imageURL ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Rectangle()
                            .fill(Color(hex: "#F97316").opacity(0.2))
                            .overlay(
                                Image(systemName: "newspaper")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color(hex: "#F97316"))
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .clipped()
                    
                    // Content Cards
                    VStack(spacing: 12) {
                        TabView(selection: $currentCard) {
                            ForEach(0..<contentCards.count, id: \.self) { index in
                                ContentCardView(text: contentCards[index])
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(height: 180)
                        
                        // Page dots
                        HStack(spacing: 6) {
                            ForEach(0..<contentCards.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentCard ? Color(hex: "#F97316") : Color.gray.opacity(0.3))
                                    .frame(
                                        width: index == currentCard ? 10 : 6,
                                        height: index == currentCard ? 10 : 6
                                    )
                                    .animation(.spring(), value: currentCard)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer(minLength: 100)
                }
            }
            
            // Ask Layman Button
            Button {
                showChat = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "bubble.left.fill")
                    Text("Ask Layman")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color(hex: "#F97316"))
                .cornerRadius(16)
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
                .shadow(color: Color(hex: "#F97316").opacity(0.4), radius: 12)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    // Link button
                    Button {
                        showWebView = true
                    } label: {
                        Image(systemName: "link")
                            .foregroundColor(.primary)
                    }
                    
                    // Bookmark button
                    Button {
                        Task { await toggleSave() }
                    } label: {
                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                            .foregroundColor(isSaved ? Color(hex: "#F97316") : .primary)
                    }
                    
                    // Share button
                    Button {
                        shareArticle()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showWebView) {
            if let urlString = article.sourceURL,
               let url = URL(string: urlString) {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
        .sheet(isPresented: $showChat) {
            ChatView(article: article)
        }
        .task {
            isSaved = (try? await SupabaseService.shared.isArticleSaved(articleId: article.id)) ?? false
        }
    }
    
    func toggleSave() async {
        do {
            if isSaved {
                try await SupabaseService.shared.unsaveArticle(articleId: article.id)
            } else {
                try await SupabaseService.shared.saveArticle(article)
            }
            isSaved.toggle()
        } catch {
            print("Save error: \(error)")
        }
    }
    
    func shareArticle() {
        guard let url = article.sourceURL else { return }
        let activityVC = UIActivityViewController(
            activityItems: [article.title, url],
            applicationActivities: nil
        )
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

// MARK: - Content Card
struct ContentCardView: View {
    let text: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 10)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .lineSpacing(6)
                .multilineTextAlignment(.leading)
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

