//
//  ContentView.swift
//  AsyncStream
//
//  Created by Kevin Montemayor on 9/29/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isEightBallViewPresented = false
    @State private var isChatViewPresented = false
    @StateObject private var chatViewModel = ChatViewModel()

    var body: some View {
        ZStack {
            Image("ElectricWaterfall")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                Spacer()
                Text("Async/Stream")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.white)
                    .padding()

                Spacer()

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            isChatViewPresented.toggle()
                        }) {
                            Text("Chat")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .fullScreenCover(isPresented: $isChatViewPresented) {
                            ChatView(viewModel: chatViewModel)
                        }

                        Spacer()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
