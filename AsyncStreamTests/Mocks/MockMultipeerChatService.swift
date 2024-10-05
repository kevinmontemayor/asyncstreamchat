//
//  MockMultipeerChatService.swift
//  AsyncStreamTests
//
//  Created by Kevin Montemayor on 10/5/24.
//

import Foundation
@testable import AsyncStream

class MockMultipeerChatService: MultipeerChatService {

    var sendMessageCalled = false
    override func sendMessage(_ message: String) async {
        sendMessageCalled = true
    }

    override var isConnected: Bool {
        return hasConnectedPeers
    }
}
