//
//  MultipeerChatService.swift
//  AsyncStream
//
//  Created by Kevin Montemayor on 09/30/24.
//

import Foundation
import MultipeerConnectivity
import SwiftUI

/// Service that handles peer-to-peer communication using MultipeerConnectivity
/// Facilitates real-time messaging and typing indicators between connected devices.
class MultipeerChatService: NSObject, ObservableObject {
    // Service type identifier used for the peer discovery and communication
    private let serviceType = "chat-service"
    
    // Unique identifier for the current device (peer)
    private var peerID: MCPeerID
    
    // Session that handles communication between peers
    private var session: MCSession
    
    // Handles advertising the current peer for nearby peer discovery
    private var advertiser: MCNearbyServiceAdvertiser
    
    // Handles browsing for nearby peers to connect to
    private var browser: MCNearbyServiceBrowser
    
    // Published array of received messages, updated in real-time as messages come in
    @Published var receivedMessages: [String] = []
    
    // Published boolean indicating if the other user is currently typing
    @Published var isOtherUserTyping = false
    
    // Track the connection state of peers
    @Published var hasConnectedPeers = false
    
    override init() {
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        self.advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        self.browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        
        super.init()
        
        // Set delegate handlers for session, advertiser, and browser
        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
        
        // Start advertising and browsing for peers
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }
    
    // Check if there are any connected peers
    var isConnected: Bool {
        !session.connectedPeers.isEmpty
    }
    
    /// Returns an async stream of incoming messages. The stream updates in real-time as messages are received.
    /// - Returns: An `AsyncStream` of messages.
    func messageStream() -> AsyncStream<String> {
        return AsyncStream { continuation in
            // Clean up and stop advertising/browsing when the stream terminates
            continuation.onTermination = { _ in
                self.advertiser.stopAdvertisingPeer()
                self.browser.stopBrowsingForPeers()
            }
            
            // Task to track and yield new messages as they come in
            Task {
                var previousCount = 0
                
                // Continuously monitor the received messages and yield new ones to the stream
                for await messages in self.$receivedMessages.values {
                    for message in messages.dropFirst(previousCount) {
                        continuation.yield(message)
                    }
                    previousCount = messages.count
                }
            }
        }
    }
    
    /// Sends a text message to all connected peers.
    /// - Parameter message: The message to be sent as a `String`.
    func sendMessage(_ message: String) async {
        guard !session.connectedPeers.isEmpty else {
            print("No connected peers to send message to.")
            return
        }
        
        // Encode the message to UTF-8 and send to all peers
        if let messageData = message.data(using: .utf8) {
            do {
                try session.send(messageData, toPeers: session.connectedPeers, with: .reliable)
                print("Sent message: \(message)")
            } catch {
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
    
    /// Sends a typing status notification to all connected peers.
    /// - Parameter isTyping: A boolean indicating whether the user is currently typing.
    func sendTypingStatus(isTyping: Bool) async {
        guard !session.connectedPeers.isEmpty else { return }
        
        // Send typing status ("typing" or "stopped_typing")
        let typingStatus = isTyping ? "typing" : "stopped_typing"
        if let messageData = typingStatus.data(using: .utf8) {
            do {
                try session.send(messageData, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                print("Error sending typing status: \(error.localizedDescription)")
            }
        }
    }
}

extension MultipeerChatService: MCSessionDelegate {
    
    /// Monitors the peer's connection state changes (connected, connecting, not connected).
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("\(peerID.displayName) connected.")
            DispatchQueue.main.async {
                self.hasConnectedPeers = true
            }
        case .notConnected:
            print("\(peerID.displayName) disconnected.")
            DispatchQueue.main.async {
                self.hasConnectedPeers = self.isConnected
            }
        default:
            break
        }
    }
    
    /// Handles receiving data from a connected peer. Updates the message list or typing status.
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let message = String(data: data, encoding: .utf8) {
            // Update typing status if the received message is typing-related
            if message == "typing" {
                DispatchQueue.main.async {
                    self.isOtherUserTyping = true
                }
            } else if message == "stopped_typing" {
                DispatchQueue.main.async {
                    self.isOtherUserTyping = false
                }
            } else {
                // Otherwise, treat it as a chat message
                DispatchQueue.main.async {
                    self.receivedMessages.append(message)
                }
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) { }
}

extension MultipeerChatService: MCNearbyServiceAdvertiserDelegate {
    
    /// Handles incoming invitations from nearby peers. Automatically accepts and joins the session.
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Received invitation from \(peerID.displayName)")
        invitationHandler(true, session)
    }
}

extension MultipeerChatService: MCNearbyServiceBrowserDelegate {
    
    /// Invites discovered peers to join the session.
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Found peer: \(peerID.displayName)")
        if !session.connectedPeers.contains(peerID) && peerID != self.peerID {
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
        }
    }
    
    /// Handles the case when a peer is lost.
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID.displayName)")
    }
}
