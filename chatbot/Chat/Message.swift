//
//  Message.swift
//  chatbot
//
//  Created by Giannis Hatziioannidis on 5/10/24.
//

import Foundation

class Message: Hashable, Identifiable {
    let id = UUID()
    var text: String
    let isUser: Bool
    
    init(text: String, isUser: Bool) {
        self.text = text
        self.isUser = isUser
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
}
