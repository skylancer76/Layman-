//
//  ProfileView.swift
//  Layman
//
//  Created by Pawan Priyatham  on 03/04/26.
//

import SwiftUI
import Auth

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSignOutAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#FFF8F0").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // Avatar
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "#FDDCB5"), Color(hex: "#F97316")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 90, height: 90)
                                Text(authViewModel.currentUser?.email?.prefix(1).uppercased() ?? "U")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Text(authViewModel.currentUser?.email ?? "")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        .padding(.top, 24)
                        
                        // Info Card
                        VStack(spacing: 0) {
                            ProfileRowView(
                                icon: "envelope.fill",
                                title: "Email",
                                value: authViewModel.currentUser?.email ?? ""
                            )
                            Divider().padding(.leading, 52)
                            ProfileRowView(
                                icon: "calendar",
                                title: "Member since",
                                value: formatDate(authViewModel.currentUser?.createdAt)
                            )
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 8)
                        .padding(.horizontal, 16)
                        
                        // Settings Card
                        VStack(spacing: 0) {
                            ProfileRowView(
                                icon: "bell.fill",
                                title: "Notifications",
                                value: "Coming soon"
                            )
                            Divider().padding(.leading, 52)
                            ProfileRowView(
                                icon: "moon.fill",
                                title: "Dark Mode",
                                value: "Coming soon"
                            )
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 8)
                        .padding(.horizontal, 16)
                        
                        // Sign Out
                        Button {
                            showSignOutAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Sign Out")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.05), radius: 8)
                            .padding(.horizontal, 16)
                        }
                        .alert("Sign Out", isPresented: $showSignOutAlert) {
                            Button("Cancel", role: .cancel) {}
                            Button("Sign Out", role: .destructive) {
                                Task { await authViewModel.signOut() }
                            }
                        } message: {
                            Text("Are you sure you want to sign out?")
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Profile")
                        .font(.system(size: 24, weight: .bold))
                }
            }
        }
    }
    
    func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Profile Row
struct ProfileRowView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "#F97316"))
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .lineLimit(1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
