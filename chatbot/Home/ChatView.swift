//
//  ContentView.swift
//  chatbot
//
//  Created by Giannis Hatziioannidis on 5/10/24.
//

import SwiftUI


struct ChatView: View {
    @ObservedObject var viewModel = ViewModel()
    var body: some View {
        VStack {
            HStack {
                Button {
                    Task {
                        await viewModel.askPermission()
                    }
                } label: {
                    Image(systemName: "lock.circle.fill")
                        .font(.largeTitle)
                }
                Button {
                    viewModel.startSpeaking()
                } label: {
                    Image(systemName: "mic.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(viewModel.isRecording ? .red : .green)
                }
                Button {
                    viewModel.stopSpeaking()
                } label: {
                    Image(systemName: "stop.circle.fill")
                        .font(.largeTitle)
                }.disabled(!viewModel.isRecording)
                Button {
                    Task {
                        await viewModel.sendMessage("")
                    }
                } label: {
                    Image(systemName: "paperplane.circle.fill")
                        .font(.largeTitle)
                }
            }

            Spacer()

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
//                            viewModel.synthesisToSpeaker(viewModel.messages[oldValue].text)
                        }
                    }
                }
            }
        }
        .padding()
    }
}

struct MessageView: View {
    let message: Message
    
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
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.black)
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
