//
//  MainTabView.swift
//  Layman
//
//  Created by Pawan Priyatham  on 03/04/26.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var articlesViewModel = ArticlesViewModel()
    @StateObject private var savedViewModel = SavedViewModel()
    
    var body: some View {
        TabView {
            HomeView()
                .environmentObject(articlesViewModel)
                .environmentObject(authViewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            SavedView()
                .environmentObject(savedViewModel)
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
            
            ProfileView()
                .environmentObject(authViewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(Color(hex: "#F97316"))
    }
}
