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

            ScrollView {
                ForEach(viewModel.messages) { message in
                    HStack {
                        if message.isUserMessage {
                            Spacer()
                            Text(message.content)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .frame(maxWidth: 250, alignment: .trailing)
                        } else {
                            Text(message.content)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .frame(maxWidth: 250, alignment: .leading)
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 4)
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
            await viewModel.sendMessage(textInput)
            textInput = ""
        }
    }
}

#Preview {
    let previewViewModel = ChatViewModel()
    
    previewViewModel.messages = [
        Message(content: "Hello, Async/Stream Chat!", isUserMessage: true),
        Message(content: "Hello, User! How are you today?", isUserMessage: false),
        Message(content: "I am doing well, thank you! How about you?", isUserMessage: true),
        Message(content: "Battery systems are at optimal levels.", isUserMessage: false),
        Message(content: "Great, are you ready to get started?", isUserMessage: true),
        Message(content: "Yes, let us begin", isUserMessage: false)
    ]
    
    return ChatView(viewModel: previewViewModel)
        .onAppear {
            previewViewModel.multipeerService.isOtherUserTyping = true
        }
}
