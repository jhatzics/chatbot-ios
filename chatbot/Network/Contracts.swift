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
    var from: From?
    var conversation: Conversation?
    var text: String?
    var locale: String?
}

struct ActivitiesResponse: Codable {
    var activities: [Activity]
    var watermark: String?
}

// Supporting models for Activity
struct From: Codable {
    var id: String
    var name: String?
    var role: String?
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

struct ConversationResponse: Codable {
    var conversationId: String
    var token: String
    var expires_in: Int
    var streamUrl: String
}

struct SendMessageResponse: Codable {
    var id: String
}
