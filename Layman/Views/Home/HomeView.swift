//
//  HomeView.swift
//  Layman
//
//  Created by Pawan Priyatham  on 03/04/26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var articlesViewModel: ArticlesViewModel
    @State private var showSearch = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#FFF8F0").ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Search bar (when active)
                        if showSearch {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                TextField("Search articles...", text: $articlesViewModel.searchQuery)
                                    .onChange(of: articlesViewModel.searchQuery) { _ in
                                        Task { await articlesViewModel.searchArticles() }
                                    }
                                if !articlesViewModel.searchQuery.isEmpty {
                                    Button {
                                        articlesViewModel.searchQuery = ""
                                        articlesViewModel.searchResults = []
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                        }
                        
                        // Search results
                        if !articlesViewModel.searchResults.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Search Results")
                                    .font(.system(size: 18, weight: .bold))
                                    .padding(.horizontal, 16)
                                
                                ForEach(articlesViewModel.searchResults) { article in
                                    NavigationLink(destination: ArticleDetailView(article: article)) {
                                        ArticleRowView(article: article)
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        } else {
                            // Featured Carousel
                            if !articlesViewModel.featuredArticles.isEmpty {
                                FeaturedCarouselView(articles: articlesViewModel.featuredArticles)
                            }
                            
                            // Today's Picks
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Today's Picks")
                                        .font(.system(size: 20, weight: .bold))
                                    Spacer()
                                    Button("View All") {}
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: "#F97316"))
                                }
                                .padding(.horizontal, 16)
                                
                                ForEach(articlesViewModel.todaysPicks) { article in
                                    NavigationLink(destination: ArticleDetailView(article: article)) {
                                        ArticleRowView(article: article)
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 24)
                }
                
                if articlesViewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Layman")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "#F97316"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation { showSearch.toggle() }
                    } label: {
                        Image(systemName: showSearch ? "xmark" : "magnifyingglass")
                            .foregroundColor(Color(hex: "#F97316"))
                    }
                }
            }
        }
        .task {
            await articlesViewModel.fetchArticles()
        }
    }
}

// MARK: - Featured Carousel
struct FeaturedCarouselView: View {
    let articles: [Article]
    @State private var currentIndex = 0
    
    var body: some View {
        VStack(spacing: 12) {
            TabView(selection: $currentIndex) {
                ForEach(Array(articles.enumerated()), id: \.offset) { index, article in
                    NavigationLink(destination: ArticleDetailView(article: article)) {
                        FeaturedCardView(article: article)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 220)
            
            // Page dots
            HStack(spacing: 6) {
                ForEach(0..<articles.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentIndex ? Color(hex: "#F97316") : Color.gray.opacity(0.3))
                        .frame(width: index == currentIndex ? 10 : 6, height: index == currentIndex ? 10 : 6)
                        .animation(.spring(), value: currentIndex)
                }
            }
        }
    }
}

// MARK: - Featured Card
struct FeaturedCardView: View {
    let article: Article
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Image
            AsyncImage(url: URL(string: article.imageURL ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(Color(hex: "#F97316").opacity(0.3))
                    .overlay(
                        Image(systemName: "newspaper")
                            .font(.system(size: 40))
                            .foregroundColor(Color(hex: "#F97316"))
                    )
            }
            .frame(height: 220)
            .clipped()
            
            // Gradient overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Headline
            Text(article.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(2)
                .padding(16)
        }
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
}

// MARK: - Article Row
struct ArticleRowView: View {
    let article: Article
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: article.imageURL ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(Color(hex: "#F97316").opacity(0.2))
                    .overlay(
                        Image(systemName: "newspaper")
                            .foregroundColor(Color(hex: "#F97316"))
                    )
            }
            .frame(width: 80, height: 80)
            .cornerRadius(12)
            .clipped()
            
            VStack(alignment: .leading, spacing: 6) {
                Text(article.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(3)
                
                Text(article.sourceName ?? "")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8)
    }
}
