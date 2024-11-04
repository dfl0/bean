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

    var body: some View {
        VStack {
            Text(formatTime(ms: msElapsed))
                .font(.title)
            HStack {
                Button("Start", action: startTimer)
                Button("Pause", action: pauseTimer)
                Button("Reset", action: resetTimer)
            }
        }
        .padding()
    }

    private func formatTime(ms: Int) -> String {
        let minutes = (ms / 1000) / 60
        let seconds = (ms / 1000) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func startTimer() {
        if (timer == nil) {
            timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { _ in
                msElapsed += 1
            }
        }
    }
    
    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func resetTimer() {
        timer?.invalidate()
        timer = nil
        msElapsed = 0
    }
}

#Preview {
    ContentView()
}
