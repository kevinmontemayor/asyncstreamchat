# AsyncStreamChat
AsyncStreamChat is a SwiftUI-based chat application that utilizes the MultipeerConnectivity framework for real-time peer-to-peer messaging between devices. This app showcases the use of AsyncStream to handle incoming messages asynchronously, while also providing a typing indicator for live interactions.

Features
Real-time Messaging: Chat with peers over a local network using the MultipeerConnectivity framework.
Typing Indicator: See when the other user is typing, updated dynamically in real-time.
AsyncStream: Efficient message handling using Swift’s AsyncStream, ensuring smooth and responsive interactions.
Multipeer Connectivity: Automatically discover and connect with other nearby devices running the app.

<img width="947" alt="asyncstreamchat-screenshot" src="https://github.com/user-attachments/assets/c9195454-bf49-458e-813e-1044a577b014">

Getting Started
To get started with the AsyncStreamChat app, follow these steps:

Prerequisites
Xcode 13+
iOS 16+
Swift 5.5+
Setup
Clone the Repository:

bash
Copy code
git clone https://github.com/username/asyncstreamchat.git
cd asyncstreamchat
Open the Project in Xcode:

bash
Copy code
open AsyncStreamChat.xcodeproj
Build and Run the App:

Build the project and run the app on either a physical device or simulators.
Ensure that both devices/simulators are on the same local network for MultipeerConnectivity to work properly.
Running Multiple Simulators
To test peer-to-peer communication, you can run multiple simulators using the following command:

bash
Copy code
open -n /Applications/Xcode.app --args -MultipleInstancesEnabled YES
Testing Multipeer Chat
On one simulator or device, type a message and send it.
On the other, the message should appear almost instantly.
You will also see a "User is typing..." indicator when the other peer begins typing a message.
How It Works
Key Components:
MultipeerChatService:

This class handles all the MultipeerConnectivity logic, including discovering peers, establishing sessions, sending and receiving messages, and broadcasting typing indicators.
ChatViewModel:

Manages the chat’s state, including messages and the real-time typing status. Utilizes AsyncStream to listen for incoming messages.
ChatView:

The main view for chatting, showing a list of messages, the typing indicator, and an input field for sending messages.
Multipeer Connectivity
The MultipeerChatService class uses the following key methods:

sendMessage(): Sends messages to connected peers.
sendTypingStatus(): Sends typing indicator updates to connected peers.
messageStream(): Uses AsyncStream to yield messages as they are received from other peers.
Contribution
Contributions are welcome! Please feel free to submit a pull request or open an issue.

How to Contribute
Fork the repository.
Create a new branch (git checkout -b feature/your-feature).
Make your changes.
Commit your changes (git commit -m "Add feature")
Push to the branch (git push origin feature/your-feature).
Create a new pull request.

License
This project is licensed under the MIT License.
