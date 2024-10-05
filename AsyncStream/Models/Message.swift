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
    let isUserMessage: Bool
}
