//
//  MultipeerServiceTests.swift
//  AsyncStreamTests
//
//  Created by Kevin Montemayor on 10/5/24.
//

import Foundation
import XCTest
@testable import AsyncStream

class MultipeerChatServiceTests: XCTestCase {

    var service: MultipeerChatService!

    override func setUp() {
        super.setUp()
        service = MultipeerChatService()
    }

    func testInitialState() {
        XCTAssertFalse(service.hasConnectedPeers)
        XCTAssertTrue(service.receivedMessages.isEmpty)
    }

    func testSendMessageWithoutPeers() async {
        await service.sendMessage("Hello, Async/Stream")
        XCTAssertTrue(service.receivedMessages.isEmpty)
    }

    func testTypingStatus() async {
        await service.sendTypingStatus(isTyping: true)
        // Since no peers were connected, nothing should happen.
        XCTAssertFalse(service.isOtherUserTyping)
    }
}
