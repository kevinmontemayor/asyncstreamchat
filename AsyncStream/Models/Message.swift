//
//  Message.swift
//  AsyncStream
//
//  Created by Kevin Montemayor on 9/29/24.
//

import Foundation

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let timestamp: Date
    let username: String
}

extension Message {
    func isUserMessage(for localUsername: String) -> Bool {
        return username == localUsername
    }
}
