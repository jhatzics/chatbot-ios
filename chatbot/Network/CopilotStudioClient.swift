//
//  BotClient.swift
//  chatbot
//
//  Created by Giannis Hatziioannidis on 6/10/24.
//

import Foundation

class CopilotStudioClient {
    private let baseURL = URL(string: "https://default250ccdaac21741e3b8a3161390bd66.4a.environment.api.powerplatform.com/powervirtualagents/botsbyschema/cr8a7_cloudBankPublicGr/")!
    
    // Shared URLSession instance
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }

    func getToken() async throws -> TokenResponse {
        var url = baseURL.appendingPathComponent("directline/token")
        url = url.appending(queryItems: [
            URLQueryItem(name: "api-version", value: "2022-03-01-preview")
        ])
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(TokenResponse.self, from: data)
    }
}
