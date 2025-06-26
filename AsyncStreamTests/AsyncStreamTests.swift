//
//  ChatViewModelTests.swift
//  AsyncStreamTests
//
//  Created by Kevin Montemayor on 10/5/24.
//

import XCTest
@testable import AsyncStream

@MainActor
class ChatViewModelTests: XCTestCase {

    var chatViewModel: ChatViewModel!
    var mockMultipeerChatService: MockMultipeerChatService!

    override func setUp() {
        super.setUp()
        mockMultipeerChatService = MockMultipeerChatService()
        chatViewModel = ChatViewModel()
        chatViewModel.multipeerService = mockMultipeerChatService
        
        // Reset sendMessageCalled before each test
        mockMultipeerChatService.sendMessageCalled = false
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSendMessageWithConnection() async {
        // Simulate a connected state
        mockMultipeerChatService.hasConnectedPeers = true
        
        await chatViewModel.sendMessage("Hi!")

        // Assert the message is sent when peers are connected, only 1 message should be present
        XCTAssertEqual(chatViewModel.messages.count, 1) // Only the user message
        XCTAssertEqual(chatViewModel.messages.first?.content, "Hi!")
        XCTAssertTrue(mockMultipeerChatService.sendMessageCalled)
    }

    func testSecretQuestionHandling() async {
        await chatViewModel.sendMessage("What is the ultimate answer to the ultimate question of the universe?")
        XCTAssertEqual(chatViewModel.messages.last?.content, "42")
    }
}

