//
//  WelcomeView.swift
//  Layman
//
//  Created by Pawan Priyatham  on 03/04/26.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var slideOffset: CGFloat = 0
    @State private var hasSlid = false
    @State private var navigateToAuth = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient - subtle peach/cream
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
                
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 40)
                    
                    // Logo
                    Text("Layman")
                        .font(.system(size: 54, weight: .bold))
                        .foregroundColor(Color(hex: "#1A1A1A"))
                    
                    Spacer()
                        .frame(height:160)
                    
                    // Slogan
                    VStack(spacing: -4) {
                        Text("Business,")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(Color(hex: "#1A1A1A"))
                        Text("tech & startups")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(Color(hex: "#1A1A1A"))
                        Text("made simple")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(Color(hex: "#C4652A"))
                    }
                    
                    Spacer()
                    Spacer()
                    
                    // Swipe to get started
                    SwipeButton(onSwipeComplete: {
                        navigateToAuth = true
                    })
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
                }
            }
            .navigationDestination(isPresented: $navigateToAuth) {
                AuthView()
                    .environmentObject(authViewModel)
            }
        }
    }
}

// MARK: - Swipe Button
struct SwipeButton: View {
    var onSwipeComplete: () -> Void
    @State private var offset: CGFloat = 0
    private let buttonWidth: CGFloat = UIScreen.main.bounds.width - 64
    private let thumbSize: CGFloat = 52
    
    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color(hex: "#C4652A"))
                .frame(height: 60)
            
            // Label
            Text("Swipe to get started")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "#FAE8D8"))
                .frame(maxWidth: .infinity)
            
            // Thumb
            Circle()
                .fill(Color.white)
                .frame(width: thumbSize, height: thumbSize)
                .overlay(
                    Image(systemName: "chevron.right.2")
                        .foregroundColor(Color(hex: "#C4652A"))
                        .font(.system(size: 18, weight: .bold))
                )
                .offset(x: 4 + offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let newOffset = min(
                                max(0, value.translation.width),
                                buttonWidth - thumbSize - 8
                            )
                            offset = newOffset
                        }
                        .onEnded { value in
                            if offset > buttonWidth * 0.6 {
                                withAnimation(.spring()) {
                                    offset = buttonWidth - thumbSize - 8
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onSwipeComplete()
                                }
                            } else {
                                withAnimation(.spring()) {
                                    offset = 0
                                }
                            }
                        }
                )
                .shadow(radius: 4)
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AuthViewModel())
}
