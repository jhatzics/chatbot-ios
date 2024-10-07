//
//  BotService.swift
//  chatbot
//
//  Created by Giannis Hatziioannidis on 6/10/24.
//

import Foundation

enum ChatError: Error {
    case notInitialized
}

class BotService {
    var csClient = CopilotStudioClient()
    var dlClient = DirectLineClient()
    private var token: String?
    private var conversationId: String?
    
    func initChat() async throws -> ConversationResponse {
        let tokenResponse = try await csClient.getToken()
        self.token = tokenResponse.token
        
        let conv = try await dlClient.startConversation(tokenResponse.token)
        self.conversationId = conv.conversationId
        return conv
    }
    
    
    func sendMessage(_ text: String) async throws {
        
        guard let token = self.token, let conversationId = self.conversationId else {
            throw ChatError.notInitialized
        }
        
        let activity = Activity(type: "message", text: text)
       
        let result = try await dlClient.sendMessage(token: token, conversationId: conversationId, activity: activity)
        print(result.id)
        
    }
}
