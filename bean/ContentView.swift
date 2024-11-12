//
//  ContentView.swift
//  bean
//
//  Created by dorin flocos on 11/3/24.
//

import SwiftUI

struct ContentView: View {
    struct TimerStats: Codable {
        var totalSeconds: Int
        var totalSessions: Int
    }

    @State private var timer: Timer?

    @State private var stats = TimerStats(
        totalSeconds: 0,
        totalSessions: 0
    )

    @State private var minsSession: Int = 25
    @State private var minsBreak: Int = 5
    @State private var msElapsed: Int = 0

    @State private var sessionComplete: Bool = false
    @FocusState private var isFieldFocused: Bool

    @State private var statusText: String = "Session"
    
    var body: some View {
        VStack {
            Text(statusText)
                .opacity(0.7)

            Text(formatTime(ms: msElapsed))
                .font(.largeTitle)
                .padding(.vertical, 5)

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

            Text("Completed \(stats.totalSessions) sessions")
                .opacity(0.7)
                .padding(.bottom, 5)

            Text("\((stats.totalSeconds / 3600) > 0 ? "\(stats.totalSeconds / 3600) hr " : "")\((stats.totalSeconds / 60 % 60) > 0 ? "\(stats.totalSeconds / 60 % 60) min " : "0 min ")total")
                .opacity(0.7)
        }
        .padding(30)
        .contentShape(.rect)
        .fixedSize(horizontal: true, vertical: false)
        .onAppear {
            loadData()
        }
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
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if (!sessionComplete) {
                    if (msElapsed < minsSession * 60 * 1000) {
                        msElapsed += 100
                        if (msElapsed % 1000 == 0) {
                            stats.totalSeconds += 1
                            saveData()
                        }
                    }
                    else {
                        pauseTimer()
                        sessionComplete = true
                        stats.totalSessions += 1
                        saveData()
                        msElapsed = 0
                        statusText = "Break"
                    }
                } else {
                    if (msElapsed < minsBreak * 60 * 1000) {
                        msElapsed += 100
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

    private func saveData() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let path = URL.applicationSupportDirectory.appendingPathComponent(Bundle.main.bundleIdentifier ?? "bean", isDirectory: true)
            let file = path.appendingPathComponent("data.json")

            let data = try encoder.encode(stats)
            try data.write(to: file)
        } catch {
            print(error)
        }
    }
    
    private func loadData() {
        let decoder = JSONDecoder()
        do {
            let path = URL.applicationSupportDirectory.appendingPathComponent(Bundle.main.bundleIdentifier ?? "bean", isDirectory: true)
            let file = path.appendingPathComponent("data.json")

            let data = try Data(contentsOf: file)

            stats = try decoder.decode(TimerStats.self, from: data)
        } catch {
            saveData()
        }
    }
}

#Preview {
    ContentView()
}
