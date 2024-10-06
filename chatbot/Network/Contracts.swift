//
//  Contracts.swift
//  chatbot
//
//  Created by Giannis Hatziioannidis on 6/10/24.
//

import Foundation

import Foundation

// Bot Framework Activity Model
struct Activity: Codable {
    var type: String
    var id: String?
    var timestamp: Date?
    var from: From?
    var conversation: Conversation?
    var text: String?
    var locale: String?
}

// Supporting models for Activity
struct From: Codable {
    var id: String
    var name: String?
}

struct Conversation: Codable {
    var id: String
    var name: String?
    var isGroup: Bool?
}

/// Token Response
struct TokenResponse: Codable {
    var token: String
    var expires_in: Int
    var conversationId: String
}
