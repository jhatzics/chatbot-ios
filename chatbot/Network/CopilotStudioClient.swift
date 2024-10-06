//
//  BotClient.swift
//  chatbot
//
//  Created by Giannis Hatziioannidis on 6/10/24.
//

import Foundation

class CopilotStudioClient {
    private let baseURL = URL(string: "https://api.clientone.com")!
    
    // Shared URLSession instance
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }

    func getToken() async throws -> TokenResponse {
        
        let url = baseURL.appendingPathComponent("/token?api-version=2022-03-01-preview")
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(TokenResponse.self, from: data)
    }
}
