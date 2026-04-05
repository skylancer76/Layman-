//
//  AuthView.swift
//  Layman
//
//  Created by Pawan Priyatham  on 03/04/26.
//

import SwiftUI
import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isLogin = true
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        ZStack {
            
            LinearGradient(
                colors: [
                    Color(hex: "#F5DCC8"),
                    Color(hex: "#FAE8D8"),
                    Color(hex: "#F2D5BE")
                ],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
            
            ZStack {
                Circle()
                    .fill(Color(hex: "#F97316").opacity(0.3))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(x: -90, y: -300)
                
                Circle()
                    .fill(Color(hex: "#C4652A").opacity(0.3))
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                    .offset(x: 90, y: 300)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 50) {
                    
                    VStack(spacing: 10) {
                        Text("Layman")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text(isLogin ? "Welcome back" : "Create your account")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black)
                    }
                    .padding(.top, 70)
                    
                    
                    VStack(spacing: 22) {
                        
                        // Toggle tabs
                        HStack(spacing: 0) {
                            ForEach(["Login", "Sign Up"], id: \.self) { tab in
                                let selected = (tab == "Login") == isLogin
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        isLogin = tab == "Login"
                                    }
                                } label: {
                                    Text(tab)
                                        .font(.system(size: 15, weight: selected ? .semibold : .regular))
                                        .foregroundColor(selected ? Color(hex: "#C4652A") : Color.black)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 42)
                                        .background(
                                            selected
                                            ? Color.white
                                            : Color.clear
                                        )
                                        .cornerRadius(10)
                                        .padding(4)
                                }
                            }
                        }
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(13)
                        
                        // Input fields
                        VStack(spacing: 14) {
                            GlassTextField(
                                placeholder: "Email address",
                                text: $email,
                                icon: "envelope.fill",
                                isSecure: false
                            )
                            
                            GlassTextField(
                                placeholder: "Password",
                                text: $password,
                                icon: "lock.fill",
                                isSecure: true
                            )
                            
                            if !isLogin {
                                GlassTextField(
                                    placeholder: "Confirm Password",
                                    text: $confirmPassword,
                                    icon: "lock.shield.fill",
                                    isSecure: true
                                )
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        
                        // Error message
                        if let error = authViewModel.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(Color(hex: "#C4652A"))
                                Text(error)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "#C4652A"))
                            }
                            .padding(12)
                            .background(Color(hex: "#C4652A").opacity(0.08))
                            .cornerRadius(10)
                        }
                        
                        // CTA Button
                        Button {
                            Task {
                                if isLogin {
                                    await authViewModel.signIn(email: email, password: password)
                                } else {
                                    guard password == confirmPassword else {
                                        authViewModel.errorMessage = "Passwords don't match"
                                        return
                                    }
                                    await authViewModel.signUp(email: email, password: password)
                                }
                            }
                        } label: {
                            ZStack {
                                LinearGradient(
                                    colors: [Color(hex: "#E8834A"), Color(hex: "#C4652A")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .frame(height: 54)
                                .cornerRadius(16)
                                .shadow(color: Color(hex: "#C4652A").opacity(0.5), radius: 12, y: 6)
                                
                                if authViewModel.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    HStack(spacing: 8) {
                                        Text(isLogin ? "Login" : "Create Account")
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundColor(.white)
                                        Image(systemName: "arrow.right")
                                            .foregroundColor(.white.opacity(0.8))
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                }
                            }
                        }
                        .disabled(authViewModel.isLoading)
                        
                    }
                    .padding(24)
                    .background(
                        // Liquid glass effect
                        ZStack {
                            RoundedRectangle(cornerRadius: 28)
                                .fill(.ultraThinMaterial)
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color.white.opacity(0.45))
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.white.opacity(0.6), lineWidth: 1)
                        }
                    )
                    .shadow(color: Color(hex: "#C4652A").opacity(0.15), radius: 24, y: 8)
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationBarBackButtonHidden(false)
        .animation(.spring(response: 0.35), value: isLogin)
    }
}

// MARK: - Glass Text Field
struct GlassTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    let isSecure: Bool
    @State private var showPassword = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(
                    isFocused
                    ? Color(hex: "#C4652A")
                    : Color(hex: "#C4652A").opacity(0.5)
                )
                .frame(width: 20)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
            
            if isSecure && !showPassword {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 15))
                    .focused($isFocused)
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 15))
                    .keyboardType(isSecure ? .default : .emailAddress)
                    .autocapitalization(.none)
                    .focused($isFocused)
            }
            
            if isSecure {
                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                        .foregroundColor(Color(hex: "#C4652A").opacity(0.5))
                        .frame(width: 20)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    isFocused
                    ? Color.white
                    : Color.white.opacity(0.5)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            isFocused
                            ? Color(hex: "#C4652A").opacity(0.4)
                            : Color.clear,
                            lineWidth: 1.5
                        )
                )
        )
        .shadow(
            color: isFocused ? Color(hex: "#C4652A").opacity(0.1) : .clear,
            radius: 8
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Toggle Button (kept for compatibility)
struct ToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? Color(hex: "#C4652A") : Color(hex: "#C4652A").opacity(0.5))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(isSelected ? Color.white : Color(hex: "#F4E7D8"))
                .cornerRadius(10)
                .padding(4)
        }
    }
}

// MARK: - Auth Text Field (kept for compatibility)
struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false
    @State private var showPassword: Bool = false
    
    var body: some View {
        GlassTextField(
            placeholder: placeholder,
            text: $text,
            icon: icon,
            isSecure: isSecure
        )
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
