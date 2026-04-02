//
//  LaymanApp.swift
//  Layman
//
//  Created by Pawan Priyatham  on 02/04/26.
//

import SwiftUI

@main
struct LaymanApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.isLoggedIn {
                MainTabView()
                    .environmentObject(authViewModel)
            } else {
                WelcomeView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
