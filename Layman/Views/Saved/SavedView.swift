//
//  SavedView.swift
//  Layman
//
//  Created by Pawan Priyatham  on 03/04/26.
//

import SwiftUI

struct SavedView: View {
    @EnvironmentObject var savedViewModel: SavedViewModel
    @State private var showSearch = false
    @State private var refreshId = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#FFF8F0").ignoresSafeArea()
                
                VStack {
                    // Header
                    Text("Saved")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, -16) // Negative padding to bring it closer to the toolbar
                    
                    // Search bar
                    if showSearch {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search saved articles...", text: $savedViewModel.searchQuery)
                            if !savedViewModel.searchQuery.isEmpty {
                                Button {
                                    savedViewModel.searchQuery = ""
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
                        .padding(.top, 4)
                    }
                    
                    if savedViewModel.isLoading && savedViewModel.savedArticles.isEmpty {
                        Spacer()
                        ProgressView()
                        Spacer()
                    } else {
                        ScrollView {
                            if savedViewModel.filteredArticles.isEmpty {
                                VStack(spacing: 16) {
                                    Spacer(minLength: 120)
                                    Image(systemName: "bookmark.slash")
                                        .font(.system(size: 48))
                                        .foregroundColor(Color(hex: "#F97316").opacity(0.4))
                                    Text(savedViewModel.searchQuery.isEmpty ? "No saved articles yet" : "No results found")
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(.gray)
                                    if savedViewModel.searchQuery.isEmpty {
                                        Text("Bookmark articles to read them later")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray.opacity(0.7))
                                    }
                                    Spacer(minLength: 120)
                                }
                                .frame(maxWidth: .infinity)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(savedViewModel.filteredArticles) { saved in
                                        SavedArticleRowView(
                                            savedArticle: saved,
                                            onUnsave: {
                                                Task {
                                                    await savedViewModel.unsaveArticle(
                                                        articleId: saved.articleId
                                                    )
                                                }
                                            }
                                        )
                                        .padding(.horizontal, 16)
                                    }
                                }
                                .padding(.vertical, 12)
                            }
                        }
                        .refreshable {
                            await savedViewModel.fetchSavedArticles()
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation { showSearch.toggle() }
                    } label: {
                        Image(systemName: showSearch ? "xmark" : "magnifyingglass")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color.black)
                    }
                }
            }
            .toolbarBackground(Color(hex: "#FFF8F0"), for: .navigationBar)
            .onAppear {
                Task {
                    await savedViewModel.fetchSavedArticles()
                }
            }
            .onChange(of: savedViewModel.needsRefresh) { _ in
                Task {
                    await savedViewModel.fetchSavedArticles()
                }
            }
        }
    }
}

// MARK: - Saved Article Row
struct SavedArticleRowView: View {
    let savedArticle: SavedArticle
    let onUnsave: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: savedArticle.imageUrl ?? "")) { image in
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
                Text(savedArticle.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(3)
                
                Text(savedArticle.createdAt?.prefix(10) ?? "")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button {
                onUnsave()
            } label: {
                Image(systemName: "bookmark.fill")
                    .foregroundColor(Color(hex: "#F97316"))
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8)
    }
}
