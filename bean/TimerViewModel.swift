//
//  TimerViewModel.swift
//  bean
//
//  Created by dorin flocos on 12/8/24.
//

import Foundation

@Observable
class TimerViewModel {
    private var timer: Timer?

    enum TimerState {
        case Session
        case Break
    }

    var minsSession: Int
    var minsBreak: Int

    var running: Bool
    var sessionComplete: Bool
    var elapsedTime: TimeInterval
    var totalTime: TimeInterval?

    var stats: TimerStats


    init() {
        minsSession = 25
        minsBreak = 5

        running = false
        sessionComplete = false
        elapsedTime = 0

        stats = TimerStats()
        loadData()
    }

    func startTimer() {
        guard (timer == nil) else { return }

        let startTime: Date = .now.addingTimeInterval(-elapsedTime)

        running = true
        timer = Timer.scheduledTimer(withTimeInterval: 1 / 60, repeats: true) { [self] _ in
            if (!sessionComplete) {
                if (elapsedTime < Double(minsSession * 60)) {
                    elapsedTime = abs(startTime.timeIntervalSinceNow)
                    stats.totalSeconds = totalTime! + elapsedTime
                } else {
                    pauseTimer()
                    sessionComplete = true
                    stats.totalSessions += 1
                    saveData()
                    totalTime = stats.totalSeconds
                    elapsedTime = 0
                }
            } else {
                if (elapsedTime < Double(minsBreak * 60)) {
                    elapsedTime = abs(startTime.timeIntervalSinceNow)
                } else {
                    pauseTimer()
                    sessionComplete = false
                    elapsedTime = 0
                }
            }
        }
    }

    func pauseTimer() {
        timer?.invalidate()
        timer = nil
        running = false
        saveData()
    }

    func resetTimer() {
        timer?.invalidate()
        timer = nil
        elapsedTime = 0
        running = false
        loadData()
    }

    func skipBreak() {
        pauseTimer()
        elapsedTime = 0
        sessionComplete = false
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
            stats = TimerStats()
            saveData()
        }

        totalTime = stats.totalSeconds
    }
}
