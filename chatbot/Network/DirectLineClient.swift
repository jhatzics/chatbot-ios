//
//  BotClient.swift
//  chatbot
//
//  Created by Giannis Hatziioannidis on 6/10/24.
//

import Foundation

class DirectLineClient {
    private let baseURL = URL(string: "https://europe.directline.botframework.com/")!
    
    // Shared URLSession instance
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }

    func startConversation(_ token: String) async throws -> ConversationResponse {
        
        let url = baseURL.appendingPathComponent("v3/directline/conversations")
        
        // Create URL Request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Perform network call
        let (data, response) = try await session.data(for: request)
        
        // Check for successful HTTP response
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw URLError(.badServerResponse)
        }
        
        guard let response = try? JSONDecoder().decode(ConversationResponse.self, from: data) else {
            let error = String(decoding: data, as: UTF8.self)
            throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: error])
        }
        
        return response
    }
    
    func sendMessage(token: String, conversationId: String, activity: Activity) async throws -> SendMessageResponse {
        
        let url = baseURL.appendingPathComponent("v3/directline/conversations/\(conversationId)/activities")
        
        // Create URL Request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = try JSONEncoder().encode(activity)

        // Perform network call
        let (data, response) = try await session.data(for: request)
        
        // Check for successful HTTP response
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        guard let response = try? JSONDecoder().decode(SendMessageResponse.self, from: data) else {
            let error = String(decoding: data, as: UTF8.self)
            throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: error])
        }
        
        return response
    }
}
