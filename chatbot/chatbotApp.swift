//
//  chatbotApp.swift
//  chatbot
//
//  Created by Giannis Hatziioannidis on 5/10/24.
//

import SwiftUI

@main
struct chatbotApp: App {
    
    @StateObject private var sharedViewModel = SharedViewModel()
    
    var body: some Scene {
        
        WindowGroup {
            ChatView()
                .environmentObject(sharedViewModel)
        }
    }
}
