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
    @State private var contentCards: [String] = []
    @State private var isLoadingContent = true
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: "#FFF8F0").ignoresSafeArea()
            
            if isLoadingContent {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(Color(hex: "#C4652A"))
                    Text("Simplifying for you...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#C4652A"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // Headline
                        Text(article.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "#1A1A1A"))
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        
                        // Article Image
                        GeometryReader { geo in
                            if let urlString = article.imageURL, let url = URL(string: urlString) {
                                CachedAsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: geo.size.width, height: 240)
                                        .clipped()
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color(hex: "#FAE8D8"))
                                        .overlay(
                                            ProgressView()
                                                .tint(Color(hex: "#C4652A"))
                                        )
                                }
                                .frame(width: geo.size.width, height: 240)
                                .cornerRadius(16)
                            } else {
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "#E8793A"), Color(hex: "#F97316")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(height: 240)
                                    .cornerRadius(16)
                                    .overlay(
                                        Image(systemName: "newspaper")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white.opacity(0.5))
                                    )
                            }
                        }
                        .frame(height: 240)
                        .padding(.horizontal, 20)
                        
                        // Content Cards — 3 swipeable parts
                        if !contentCards.isEmpty {
                            VStack(spacing: 12) {
                                TabView(selection: $currentCard) {
                                    ForEach(0..<contentCards.count, id: \.self) { index in
                                        ContentCardView(text: contentCards[index])
                                            .tag(index)
                                    }
                                }
                                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                                .frame(height: 200)
                                
                                // Page dots
                                HStack(spacing: 6) {
                                    ForEach(0..<contentCards.count, id: \.self) { index in
                                        Circle()
                                            .fill(index == currentCard ? Color(hex: "#C4652A") : Color.gray.opacity(0.3))
                                            .frame(
                                                width: index == currentCard ? 10 : 6,
                                                height: index == currentCard ? 10 : 6
                                            )
                                            .animation(.spring(), value: currentCard)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
                
                // Ask Layman Button — fixed at bottom
                Button {
                    showChat = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Ask Layman")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color(hex: "#C4652A"))
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                    .shadow(color: Color(hex: "#C4652A").opacity(0.3), radius: 12)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 14) {
                    Button {
                        showWebView = true
                    } label: {
                        Image(systemName: "link")
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "#1A1A1A"))
                    }
                    
                    Button {
                        Task { await toggleSave() }
                    } label: {
                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 15))
                            .foregroundColor(isSaved ? Color(hex: "#C4652A") : Color(hex: "#1A1A1A"))
                    }
                    
                    Button {
                        shareArticle()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "#1A1A1A"))
                    }
                }
            }
        }
        .toolbarBackground(Color(hex: "#FFF8F0"), for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
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
            await loadContent()
        }
    }
    
    // MARK: - Load Content via Groq AI
    func loadContent() async {
        isLoadingContent = true
        
        async let savedCheck: Bool = (try? SupabaseService.shared.isArticleSaved(articleId: article.id)) ?? false
        
        let articleContext = "\(article.title). \(article.description ?? "")"
        
        do {
            let summary = try await GroqService.shared.generateLaymanSummary(articleContext: articleContext)
            
            let sentences = splitIntoSentences(summary)
            var cards: [String] = []
            
            if sentences.count >= 6 {
                for i in stride(from: 0, to: min(6, sentences.count), by: 2) {
                    let end = min(i + 2, sentences.count)
                    cards.append(sentences[i..<end].joined(separator: " "))
                    if cards.count == 3 { break }
                }
            } else if sentences.count >= 3 {
                let perCard = max(1, sentences.count / 3)
                for i in stride(from: 0, to: sentences.count, by: perCard) {
                    let end = min(i + perCard, sentences.count)
                    cards.append(sentences[i..<end].joined(separator: " "))
                    if cards.count == 3 { break }
                }
            } else {
                cards = sentences
            }
            
            if cards.isEmpty { cards = [summary] }
            if cards.count > 3 { cards = Array(cards.prefix(3)) }
            
            contentCards = cards
        } catch {
            let fallbackText = article.description ?? "No content available for this article."
            contentCards = fallbackSplit(fallbackText)
        }
        
        isSaved = await savedCheck
        
        withAnimation(.easeIn(duration: 0.3)) {
            isLoadingContent = false
        }
    }
    
    private func splitIntoSentences(_ text: String) -> [String] {
        var sentences: [String] = []
        text.enumerateSubstrings(in: text.startIndex..., options: .bySentences) { substring, _, _, _ in
            if let sentence = substring?.trimmingCharacters(in: .whitespacesAndNewlines), !sentence.isEmpty {
                sentences.append(sentence)
            }
        }
        return sentences
    }
    
    private func fallbackSplit(_ text: String) -> [String] {
        let words = text.split(separator: " ").map(String.init)
        guard words.count > 3 else { return [text] }
        let chunkSize = max(1, words.count / 3)
        var cards: [String] = []
        for i in 0..<3 {
            let start = i * chunkSize
            let end = min(start + chunkSize, words.count)
            if start < words.count {
                cards.append(words[start..<end].joined(separator: " "))
            }
        }
        return cards
    }
    
    func toggleSave() async {
        let previousState = isSaved
        
        // Optimistic UI update
        // We do this immediately so the bookmark icon turns filled instantly
        withAnimation {
            isSaved.toggle()
        }
        
        do {
            if previousState {
                try await SupabaseService.shared.unsaveArticle(articleId: article.id)
            } else {
                try await SupabaseService.shared.saveArticle(article)
            }
        } catch {
            print("Save error: \(error)")
            // Revert if network call or constraints fail
            withAnimation {
                isSaved = previousState
            }
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
                .fill(Color(hex: "#F4E7D8"))
                .shadow(color: Color(hex: "#C4652A").opacity(0.08), radius: 8)
            
            Text(text)
                .font(.system(size: 17))
                .foregroundColor(Color(hex: "#1A1A1A"))
                .lineSpacing(6)
                .multilineTextAlignment(.leading)
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}
