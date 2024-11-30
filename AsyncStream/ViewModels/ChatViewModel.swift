//
//  ChatViewModel.swift
//  AsyncStream
//
//  Created by Kevin Montemayor on 10/1/24.
//

import Foundation
import SwiftUI

/// Handles sending and receiving messages as well as user typing status.
@MainActor
class ChatViewModel: ObservableObject {
    
    // Published list of messages that is updated in real-time
    @Published var messages: [Message] = []
    
    // Instance of MultipeerChatService that handles communication between peers
    var multipeerService = MultipeerChatService()
    
    // List of unavailable messages to return when no peer is connected
    let unavailableMessages = [
        "Sorry, I'm currently unavailable. Please try again later.",
        "Oops, no connection right now. Try sending your message again.",
        "I'm not available at the moment. Check back later!",
        "Unable to send your message. Please try again soon.",
        "It seems I'm offline right now. Please try again later."
    ]
    
    let localUsername: String
    let remoteUsername: String
    
    /// Initializes the `ChatViewModel` and starts listening for incoming messages.
    init(localUsername: String = UIDevice.current.name, remoteUsername: String = "User 2") {
        self.localUsername = localUsername
        self.remoteUsername = remoteUsername
        Task {
            await listenForMessages()
        }
    }
    
    /// Sends a user message and updates the chat interface.
    /// The message is appended to the list of messages and sent to other peers.
    /// - Parameter userMessage: The message to be sent, created by the user.
    func sendMessage(_ userMessage: String, fromUser username: String) async {
        let userMessageObject = Message(
            content: userMessage,
            timestamp: Date(),
            username: username
        )
        messages.append(userMessageObject)
        
        if !multipeerService.isConnected {
            if userMessage.lowercased() == "what is the ultimate answer to the ultimate question of the universe?" {
                let secretAnswer = Message(
                    content: "42",
                    timestamp: Date(),
                    username: remoteUsername
                )
                messages.append(secretAnswer)
            } else {
                let randomUnavailableMessage = unavailableMessages.randomElement() ?? "Sorry, please try again later."
                let unavailableMessage = Message(
                    content: randomUnavailableMessage,
                    timestamp: Date(),
                    username: "System"
                )
                messages.append(unavailableMessage)
            }
        } else {
            // Pass the username to the MultipeerChatService sendMessage function
            await multipeerService.sendMessage(userMessage, from: username)
            await multipeerService.sendTypingStatus(isTyping: false)
        }
    }
    
    /// Updates the typing status of the user and sends it to connected peers.
    /// This function is called when the user starts or stops typing in the chat input.
    /// - Parameter isTyping: Boolean indicating whether the user is typing or not.
    func userStartedTyping(isTyping: Bool) {
        Task {
            await multipeerService.sendTypingStatus(isTyping: isTyping)
        }
    }
    
    /// Listens for incoming messages from other peers using the MultipeerChatService.
    /// When a message is received, it is appended to the local list of messages as a bot (or other user) message.
    private func listenForMessages() async {
        for await rawMessage in multipeerService.messageStream() {
            let messageUsername = determineSender(rawMessage)
            let messageContent = extractContent(rawMessage)
            let botMessage = Message(
                content: messageContent,
                timestamp: Date(),
                username: messageUsername
            )
            messages.append(botMessage)
        }
    }
    
    /// Helper function to extract the content of a message without the username prefix.
    /// Assumes messages are in the format "username: messageContent".
    private func extractContent(_ rawMessage: String) -> String {
        let components = rawMessage.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
        if components.count == 2 {
            return String(components[1]).trimmingCharacters(in: .whitespaces)
        } else {
            return rawMessage
        }
    }
    
    /// Determines the sender of a message based on its format.
    /// Assumes messages are in the format "username: messageContent".
    /// - Parameter rawMessage: The raw message string received.
    /// - Returns: The username extracted from the message or a default value.
    func determineSender(_ rawMessage: String) -> String {
        // Split the message into two parts: username and content
        let components = rawMessage.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
        
        // Return the username if it exists, otherwise default to "Unknown"
        if components.count == 2 {
            return String(components[0]).trimmingCharacters(in: .whitespaces)
        } else {
            print("Error: Message format is invalid - '\(rawMessage)'")
            return "Unknown"
        }
    }
}
