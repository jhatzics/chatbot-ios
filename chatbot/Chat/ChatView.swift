//
//  ContentView.swift
//  chatbot
//
//  Created by Giannis Hatziioannidis on 5/10/24.
//

import SwiftUI


struct ChatView: View {
    @EnvironmentObject var viewModel: SharedViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    ScrollView {
                        ScrollViewReader { proxy in
                            VStack {
                                ForEach(viewModel.messages) { message in
                                    MessageView(message: message)
                                }
                            }
                            .onChange(of: viewModel.messages.count) { oldValue, newValue in
                                withAnimation {
                                    proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemGray6))
                        TextField("Type a message...", text: $viewModel.inputText)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                    }
                    .frame(height: 40)
                    
                    Spacer(minLength: 12)
                    
                    NavigationLink(destination: VoiceView()) {
                        Image(systemName: "phone.arrow.up.right")
                            .font(.title)
                    }
                    
                    Spacer(minLength: 12)
                    
                    Button {
                        Task {
                            await viewModel.sendMessage()
                        }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.title)
                    }
                }

            }
            .padding()
        }
        .onAppear {
            Task {
                await viewModel.askPermission()
            }
        }
    }
}

struct MessageView: View {
    let message: Message
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.text)
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
            } else {
                Text(message.text)
                    .padding(10)
                    .background(Color.gray.opacity(colorScheme == .dark ? 0.8 : 0.2))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                Spacer()
            }
        }
    }
}

#Preview {
    ChatView()
}
