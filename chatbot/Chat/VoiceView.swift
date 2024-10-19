//
//  VoiceView.swift
//  chatbot
//
//  Created by Giannis Hatziioannidis on 19/10/24.
//

import SwiftUI

struct VoiceView: View {
    @EnvironmentObject var viewModel: SharedViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea() // Extends the black background to fill the entire screen
            VStack {
                Text("Voice chat screen")
                    .foregroundColor(.white)
                    .padding()
                
                Spacer()
                
                ZStack(alignment: .center) {
                            Circle()
                                .fill(Color.white)
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .frame(width: 200, height: 200)
                                .animation(
                                    Animation.easeInOut(duration: 1)
                                        .repeatForever(autoreverses: true),
                                    value: isAnimating
                                )

                            Text("AI Assistant")
                                .font(.title)
                                .foregroundColor(.black)
                        }
                        .onAppear {
                            isAnimating = true
                        }
                
                Spacer()
                
                HStack {
                    Button {
                        viewModel.stopSpeaking()
                    } label: {
                        Image(systemName: "pause.circle.fill")
                            .font(.custom("FontAwesome", size: .init(68)))
                            .foregroundColor(Color.white)
                    }
                    
                    Spacer()
                    
                    Button {
                        viewModel.stopRecording()
                        viewModel.mode = .chat
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.custom("FontAwesome", size: .init(68)))
                            .foregroundColor(Color.red)
                    }
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(Color.blue)
        .onAppear {
            viewModel.startSpeaking()
            viewModel.mode = .voice
        }
    }
}
