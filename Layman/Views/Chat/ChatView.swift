//
//  ChatView.swift
//  Layman
//
//  Created by Pawan Priyatham  on 03/04/26.
//

import SwiftUI

struct ChatView: View {
    let article: Article
    @StateObject private var viewModel: ChatViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var isInputFocused: Bool
    
    init(article: Article) {
        self.article = article
        _viewModel = StateObject(wrappedValue: ChatViewModel(article: article))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#FFF8F0").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Messages
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(viewModel.messages) { message in
                                    ChatBubbleView(message: message)
                                        .id(message.id)
                                }
                                
                                // Suggestions
                                if viewModel.messages.count == 1 && !viewModel.suggestions.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Question Suggestions")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.gray)
                                            .padding(.horizontal, 16)
                                        
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 8) {
                                                ForEach(viewModel.suggestions, id: \.self) { suggestion in
                                                    Button {
                                                        Task {
                                                            await viewModel.sendMessage(suggestion)
                                                        }
                                                    } label: {
                                                        Text(suggestion)
                                                            .font(.system(size: 13, weight: .medium))
                                                            .foregroundColor(.white)
                                                            .padding(.horizontal, 14)
                                                            .padding(.vertical, 10)
                                                            .background(Color(hex: "#F97316"))
                                                            .cornerRadius(20)
                                                    }
                                                }
                                            }
                                            .padding(.horizontal, 16)
                                        }
                                    }
                                }
                                
                                // Loading indicator
                                if viewModel.isLoading {
                                    HStack {
                                        BotIconView()
                                        LoadingDotsView()
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                            .padding(.vertical, 16)
                        }
                        .onChange(of: viewModel.messages.count) { _ in
                            withAnimation {
                                proxy.scrollTo(viewModel.messages.last?.id)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Input Bar
                    HStack(spacing: 12) {
                        HStack(spacing: 8) {
                            TextField("Type your question...", text: $viewModel.inputText)
                                .font(.system(size: 15))
                                .focused($isInputFocused)
                            
                            // Mic button (placeholder)
                            Button {
                                // placeholder
                            } label: {
                                Image(systemName: "mic")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.gray.opacity(0.2))
                        )
                        
                        // Send button
                        Button {
                            Task {
                                await viewModel.sendMessage(viewModel.inputText)
                            }
                        } label: {
                            Image(systemName: "arrow.up")
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(
                                    viewModel.inputText.isEmpty
                                    ? Color.gray.opacity(0.3)
                                    : Color(hex: "#F97316")
                                )
                                .clipShape(Circle())
                        }
                        .disabled(viewModel.inputText.isEmpty || viewModel.isLoading)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#FFF8F0"))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.down")
                            .foregroundColor(.primary)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Ask Layman")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
        }
    }
}

// MARK: - Chat Bubble
struct ChatBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if !message.isUser {
                BotIconView()
            }
            
            if message.isUser { Spacer() }
            
            Text(message.content)
                .font(.system(size: 15))
                .foregroundColor(message.isUser ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    message.isUser
                    ? Color(hex: "#F97316")
                    : Color.white
                )
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.05), radius: 4)
            
            if !message.isUser { Spacer() }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Bot Icon
struct BotIconView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "#F97316"))
                .frame(width: 32, height: 32)
            Text("L")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Loading Dots
struct LoadingDotsView: View {
    @State private var animate = false
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 8, height: 8)
                    .offset(y: animate ? -4 : 0)
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever()
                        .delay(Double(index) * 0.15),
                        value: animate
                    )
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(18)
        .onAppear { animate = true }
    }
}
