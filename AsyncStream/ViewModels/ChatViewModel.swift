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
    
    /// Initializes the `ChatViewModel` and starts listening for incoming messages.
    init() {
        Task {
            await listenForMessages()
        }
    }
    
    /// Sends a user message and updates the chat interface.
    /// The message is appended to the list of messages and sent to other peers.
    /// - Parameter userMessage: The message to be sent, created by the user.
    func sendMessage(_ userMessage: String) async {
        let userMessageObject = Message(content: userMessage, isUserMessage: true)
        messages.append(userMessageObject)
        
        if !multipeerService.isConnected {
            if userMessage.lowercased() == "what is the ultimate answer to the ultimate question of the universe?" {
                let secretAnswer = Message(content: "42", isUserMessage: false)
                messages.append(secretAnswer)
            } else {
                let randomUnavailableMessage = unavailableMessages.randomElement() ?? "Sorry, please try again later."
                let unavailableMessage = Message(content: randomUnavailableMessage, isUserMessage: false)
                messages.append(unavailableMessage)
            }
        } else {
            // Now await the task for sending message and typing status
            await multipeerService.sendMessage(userMessage)
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
        for await message in multipeerService.messageStream() {
            // Received messages are treated as bot/other user messages
            let botMessage = Message(content: message, isUserMessage: false)
            messages.append(botMessage)
        }
    }
}
