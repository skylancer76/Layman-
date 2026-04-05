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
                .environmentObject(savedViewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            SavedView()
                .environmentObject(savedViewModel)
                .tabItem {
                    Label("Saved", systemImage: "bookmark")
                }
            
            ProfileView()
                .environmentObject(authViewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
        }
        .tint(Color(hex: "#C4652A"))
    }
}
