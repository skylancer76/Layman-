//
//  AuthView.swift
//  Layman
//
//  Created by Pawan Priyatham  on 03/04/26.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isLogin = true
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(hex: "#FDDCB5"),
                    Color(hex: "#F97316")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Logo
                    VStack(spacing: 8) {
                        Text("Layman")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        Text(isLogin ? "Welcome back" : "Create your account")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 60)
                    
                    // Card
                    VStack(spacing: 20) {
                        // Toggle
                        HStack(spacing: 0) {
                            ToggleButton(title: "Login", isSelected: isLogin) {
                                withAnimation { isLogin = true }
                            }
                            ToggleButton(title: "Sign Up", isSelected: !isLogin) {
                                withAnimation { isLogin = false }
                            }
                        }
                        .background(Color(hex: "#FFF8F0"))
                        .cornerRadius(12)
                        
                        // Fields
                        VStack(spacing: 16) {
                            AuthTextField(
                                placeholder: "Email",
                                text: $email,
                                icon: "envelope"
                            )
                            
                            AuthTextField(
                                placeholder: "Password",
                                text: $password,
                                icon: "lock",
                                isSecure: true
                            )
                            
                            if !isLogin {
                                AuthTextField(
                                    placeholder: "Confirm Password",
                                    text: $confirmPassword,
                                    icon: "lock.fill",
                                    isSecure: true
                                )
                            }
                        }
                        
                        // Error
                        if let error = authViewModel.errorMessage {
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Button
                        Button {
                            Task {
                                if isLogin {
                                    await authViewModel.signIn(
                                        email: email,
                                        password: password
                                    )
                                } else {
                                    guard password == confirmPassword else {
                                        authViewModel.errorMessage = "Passwords don't match"
                                        return
                                    }
                                    await authViewModel.signUp(
                                        email: email,
                                        password: password
                                    )
                                }
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(hex: "#F97316"))
                                    .frame(height: 54)
                                
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text(isLogin ? "Login" : "Create Account")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .disabled(authViewModel.isLoading)
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.08), radius: 20)
                    .padding(.horizontal, 24)
                }
            }
        }
        .navigationBarBackButtonHidden(false)
    }
}

// MARK: - Toggle Button
struct ToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : Color(hex: "#F97316"))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(isSelected ? Color(hex: "#F97316") : Color.clear)
                .cornerRadius(10)
                .padding(4)
        }
    }
}

// MARK: - Auth Text Field
struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "#F97316"))
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 16))
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
        }
        .padding(16)
        .background(Color(hex: "#FFF8F0"))
        .cornerRadius(12)
    }
}
