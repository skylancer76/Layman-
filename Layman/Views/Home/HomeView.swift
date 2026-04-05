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
                                    .padding(.top, 4)
                            }
                            
                            // Today's Picks
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Today's Picks")
                                        .font(.system(size: 20, weight: .bold))
                                    Spacer()
                                    Button("View All") {}
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: "#C4652A"))
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
                .refreshable {
                    await articlesViewModel.fetchArticles()
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
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                        .fixedSize()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation { showSearch.toggle() }
                    } label: {
                        Image(systemName: showSearch ? "xmark" : "magnifyingglass")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
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
                        .fill(index == currentIndex ? Color(hex: "#C4652A") : Color.gray.opacity(0.3))
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
            GeometryReader { geo in
                // Image with caching
                if let urlString = article.imageURL, let url = URL(string: urlString) {
                    CachedAsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    } placeholder: {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#E8793A"), Color(hex: "#F97316")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                Image(systemName: "newspaper")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.5))
                            )
                    }
                } else {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#E8793A"), Color(hex: "#F97316")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Image(systemName: "newspaper")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.5))
                        )
                }
            }
            
            // Gradient overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .center,
                endPoint: .bottom
            )
            
            // Headline
            Text(article.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .padding(16)
        }
        .frame(height: 220)
        .clipped()
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
}

// MARK: - Article Row
struct ArticleRowView: View {
    let article: Article
    
    var body: some View {
        HStack(spacing: 12) {
            // Image with caching
            if let urlString = article.imageURL, let url = URL(string: urlString) {
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "#FAE8D8"))
                        .overlay(
                            Image(systemName: "newspaper")
                                .foregroundColor(Color(hex: "#C4652A"))
                        )
                }
                .frame(width: 80, height: 80)
                .cornerRadius(12)
                .clipped()
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "#FAE8D8"))
                    .overlay(
                        Image(systemName: "newspaper")
                            .foregroundColor(Color(hex: "#C4652A"))
                    )
                    .frame(width: 80, height: 80)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(article.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                if let source = article.sourceName, !source.isEmpty {
                    Text(source)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(hex: "#F4E7D8"))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 6)
    }
}

// MARK: - Image Cache Manager
final class ImageCacheManager {
    static let shared = ImageCacheManager()
    let cache: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        return cache
    }()
    private init() {}
}

// MARK: - Cached Async Image
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder
    
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else {
                placeholder()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }
    
    private func loadImage() {
        if let cached = ImageCacheManager.shared.cache.object(forKey: url as NSURL) {
            self.image = cached
            return
        }
        
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data, let uiImage = UIImage(data: data) else { return }
            ImageCacheManager.shared.cache.setObject(uiImage, forKey: url as NSURL)
            DispatchQueue.main.async {
                self.image = uiImage
            }
        }.resume()
    }
}

#Preview {
    HomeView()
        .environmentObject(ArticlesViewModel())
}
