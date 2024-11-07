//
//  ContentView.swift
//  bean
//
//  Created by dorin flocos on 11/3/24.
//

import SwiftUI

struct ContentView: View {
    @State private var timer: Timer?

    @State private var msElapsed: Int = 0
    @State private var minsSession: Int = 25
    @State private var minsBreak: Int = 5

    @State private var sessionComplete: Bool = false
    @State private var totalSessions: Int = 0

    @FocusState private var isFieldFocused: Bool

    @State private var statusText: String = "Session"

    var body: some View {
        VStack {
            Text(statusText)
                .opacity(0.75)

            Text(formatTime(ms: msElapsed))
                .font(.largeTitle)
                .padding(.vertical, 4)

            VStack {
                HStack {
                    Button("Start", action: startTimer)
                    Button("Pause", action: pauseTimer)
                    Button("Reset", action: resetTimer)
                }

                sessionComplete
                    ? Button("Skip break", action: skipBreak)
                    : nil
            }
            .padding(.bottom)

            HStack {
                Text("Session:")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("25", value: $minsSession, format: .number)
                    .focused($isFieldFocused)
                    .onSubmit { isFieldFocused = false }
                    .frame(width: 30)
                    .multilineTextAlignment(.trailing)
                Text("min")
            }

            HStack {
                Text("Break:")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("5", value: $minsBreak, format: .number)
                    .focused($isFieldFocused)
                    .onSubmit { isFieldFocused = false }
                    .frame(width: 30)
                    .multilineTextAlignment(.trailing)
                Text("min")
            }
            .padding(.bottom)

            Text("Completed \(totalSessions) sessions")
                .opacity(0.75)
        }
        .padding(40)
        .contentShape(.rect)
        .fixedSize(horizontal: true, vertical: false)
        .onTapGesture {
            isFieldFocused = false
        }
    }

    private func formatTime(ms: Int) -> String {
        let minutes = (ms / 1000) / 60
        let seconds = (ms / 1000) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func startTimer() {
        if (timer == nil) {
            timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { _ in
                if (!sessionComplete) {
                    if (msElapsed < minsSession * 60 * 1000) {
                        msElapsed += 1
                    }
                    else {
                        pauseTimer()
                        sessionComplete = true
                        msElapsed = 0
                        totalSessions += 1
                        statusText = "Break"
                    }
                } else {
                    if (msElapsed < minsBreak * 60 * 1000) {
                        msElapsed += 1
                    }
                    else {
                        pauseTimer()
                        sessionComplete = false
                        msElapsed = 0
                        statusText = "Session"
                    }
                }
            }
        }
    }
    
    private func pauseTimer() {
        if (timer != nil) {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func resetTimer() {
        timer?.invalidate()
        timer = nil
        msElapsed = 0
        statusText = sessionComplete ? "Break" : "Session"
    }

    private func skipBreak() {
        timer?.invalidate()
        timer = nil
        msElapsed = 0
        sessionComplete = false
        statusText = "Session"
        startTimer()
    }
}

#Preview {
    ContentView()
}
