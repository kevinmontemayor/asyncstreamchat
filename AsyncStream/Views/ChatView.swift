//
//  ChatView.swift
//  AsyncStream
//
//  Created by Kevin Montemayor on 10/1/24.
//

import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    @State private var textInput = ""
    @State private var isOtherUserTyping = false
    @FocusState private var isTextFieldFocused: Bool

    private var isDisabled: Bool {
        textInput.isEmpty
    }

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
                .padding()

                Spacer()
            }

            Spacer()

            ScrollViewReader { proxy in
                ScrollView {
                    ForEach(viewModel.messages) { message in
                        HStack(alignment: .top) {
                            if message.isUserMessage(for: viewModel.localUsername) {
                                Spacer()
                                VStack(alignment: .trailing) {
                                    HStack {
                                        Text(message.username)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text(message.timestamp, style: .time)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    Text(message.content)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .frame(maxWidth: 250, alignment: .trailing)
                                }
                            } else {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(message.username)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text(message.timestamp, style: .time)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    Text(message.content)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                        .frame(maxWidth: 250, alignment: .leading)
                                }
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .id(message.id)
                    }
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let lastMessage = viewModel.messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }

            if isOtherUserTyping {
                HStack {
                    Text("User is typing...")
                        .foregroundColor(.gray)
                        .italic()
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 4)
            }

            HStack {
                TextField("Type your message...", text: $textInput)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .frame(minHeight: 40)
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        Task {
                            await sendMessage()
                        }
                    }
                    .onTapGesture {
                        isTextFieldFocused = true
                    }
                    .onChange(of: textInput) { oldValue, newValue in
                        viewModel.userStartedTyping(isTyping: !newValue.isEmpty)
                    }

                Button(action: {
                    Task {
                        await sendMessage()
                    }
                }) {
                    Text("Send")
                        .padding()
                        .background(isDisabled ? Color.gray : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(isDisabled)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isTextFieldFocused = true
            }
            .padding()
        }
        .navigationTitle("Chat")
        .onReceive(viewModel.multipeerService.$isOtherUserTyping) { typing in
            isOtherUserTyping = typing
        }
    }

    private func sendMessage() async {
        if !textInput.isEmpty {
            await viewModel.sendMessage(textInput, fromUser: viewModel.localUsername)
            textInput = ""
        }
    }
}

#Preview("ChatView Preview") {
    // Explicitly define the type of the previewViewModel
    let previewViewModel = ChatViewModel(localUsername: "Edgar Cayce", remoteUsername: "Dr. Jones")
    
    // Adding messages with usernames and timestamps
    previewViewModel.messages = [
        Message(content: "Hello, Async/Stream Chat!", timestamp: Date().addingTimeInterval(-300), username: "Edgar Cayce"),
        Message(content: "Hello, User! How are you today?", timestamp: Date().addingTimeInterval(-290), username: "Dr. Jones"),
        Message(content: "I am doing well, thank you! How about you?", timestamp: Date().addingTimeInterval(-280), username: "Edgar Cayce"),
        Message(content: "Battery systems are at optimal levels.", timestamp: Date().addingTimeInterval(-270), username: "Dr. Jones"),
        Message(content: "Great, are you ready to get started?", timestamp: Date().addingTimeInterval(-260), username: "Edgar Cayce"),
        Message(content: "Yes, let us begin", timestamp: Date().addingTimeInterval(-250), username: "Dr. Jones")
    ]
    
    // Return the ChatView with the initialized previewViewModel
    return ChatView(viewModel: previewViewModel)
        .onAppear {
            previewViewModel.multipeerService.isOtherUserTyping = true
        }
}
