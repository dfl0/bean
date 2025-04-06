//
//  TimerViewModel.swift
//  bean
//
//  Created by dorin flocos on 12/8/24.
//

import SwiftUI

class TimerViewModel: ObservableObject {
    private var timer: DispatchSourceTimer?
    var speed: Double

    var minsSession: Int
    var minsBreak: Int
    var numSessions: Int

    @Published var running: Bool
    @Published var sessionComplete: Bool
    @Published var elapsedTime: TimeInterval
    @Published var sessionsDone: Int
    var startTime: Date!
    var totalTime: TimeInterval?

    var stats: TimerStats


    init() {
        speed = 1.0 // a value of 1 results in a real-time timer (used to change speed for debugging purposes)

        minsSession = 25
        minsBreak = 5
        numSessions = 4

        running = false
        sessionComplete = false
        elapsedTime = 0
        sessionsDone = 0

        stats = TimerStats()
        loadData()
    }

    func startTimer() {
        guard (timer == nil) else { return }

        startTime = Date().addingTimeInterval(TimeInterval(-elapsedTime/speed))

        let queue = DispatchQueue(label: "bean-timer")
        timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)

        timer!.schedule(deadline: .now(), repeating: speed == 1.0 ? .seconds(1) : .milliseconds(Int(1000/speed)), leeway: .milliseconds(50))
        timer!.setEventHandler(handler: tickTimer)

        timer!.resume()
        running = true
    }

    func pauseTimer() {
        timer?.cancel()
        timer = nil
        running = false
        saveData()
    }

    func resetTimer() {
        timer?.cancel()
        timer = nil
        running = false
        elapsedTime = 0
        loadData()
    }

    func skipBreak() {
        pauseTimer()
        elapsedTime = 0
        sessionComplete = false
        startTimer()
    }

    private func tickTimer() {
        DispatchQueue.main.async { [self] in
            guard running else { return }

            let targetInterval = TimeInterval((!sessionComplete
                                               ? minsSession
                                               : (sessionsDone == numSessions ? 2*minsBreak : minsBreak)) * 60)

            elapsedTime = min(Date().timeIntervalSince(startTime) * speed, targetInterval)

            if elapsedTime >= targetInterval {
                !sessionComplete ? endSession() : endBreak()
            }
        }
    }

    private func endSession() {
        playSystemSound("Purr", volume: 0.5)
        stats.totalSessions += 1
        pauseTimer()
        totalTime = stats.totalSeconds
        sessionComplete = true
        sessionsDone = sessionsDone % numSessions + 1
        elapsedTime = 0

        if !NSApp.isActive {
            NSApp.windows.first?.level = .floating
        }
    }

    private func endBreak() {
        playSystemSound("Frog", volume: 0.5)
        pauseTimer()
        sessionComplete = false
        elapsedTime = 0

        if sessionsDone == numSessions { sessionsDone = 0 }

        if !NSApp.isActive {
            NSApp.windows.first?.level = .floating
        }
    }

    private func saveData() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let path = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let dir = path.appendingPathComponent(Bundle.main.bundleIdentifier ?? "bean", isDirectory: true)
            let file = dir.appendingPathComponent("data.json")

            if !FileManager.default.fileExists(atPath: dir.path) {
                try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
            }

            let data = try encoder.encode(stats)
            try data.write(to: file)
        } catch {
            print("Failed to save data:", error)
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
            stats = TimerStats()
            saveData()
        }

        totalTime = stats.totalSeconds
    }
}
