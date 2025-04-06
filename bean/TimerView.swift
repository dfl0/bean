//
//  TimerView.swift
//  bean
//
//  Created by dorin flocos on 12/8/24.
//

import SwiftUI

struct TimerView: View {
    @ObservedObject private var vm = TimerViewModel()

    @State private var isFieldFocusable = false
    @FocusState private var isFieldFocused: Bool

    var body: some View {
        VStack(spacing: 5) {
            Text(!vm.sessionComplete
                 ? "Session"
                 : vm.sessionsDone != vm.numSessions
                   ? "Break"
                   : "Long Break")
                .opacity(0.7)

            Text("[\(vm.speed.formatted())x as fast]")
                .opacity(0.7)
                .hidden(vm.speed == 1)

            VStack(spacing: 5){
                Text(formatTime(sec: vm.elapsedTime))
                    .font(.largeTitle)
                    .monospacedDigit()

                HStack(spacing: 0) {
                    ForEach(0..<vm.numSessions, id: \.self) { i in
                        Circle()
                            .frame(maxWidth: .infinity, maxHeight: 5)
                            .opacity(i < vm.sessionsDone ? 1 : 0.25)
                    }
                }
                .frame(maxWidth: 50)
            }
            .padding(.vertical, 5)
            .fixedSize()

            VStack {
                HStack {
                    !(vm.running)
                    ? Button(action: {
                        vm.startTimer()
                    }, label: {
                        Text(vm.elapsedTime == 0 ? "Start" : "Resume")
                            .padding(.vertical, 2)
                            .frame(maxWidth: .infinity)
                    })
                    : Button(action: {
                        vm.pauseTimer()
                    }, label: {
                        Text("Pause")
                            .padding(.vertical, 2)
                            .frame(maxWidth: .infinity)
                    })

                    !(vm.sessionComplete)
                    ? Button(action: {
                        vm.resetTimer()
                    }, label: {
                        Text("Reset")
                            .padding(.vertical, 2)
                            .frame(maxWidth: .infinity)
                    })
                    : Button(action: {
                        vm.skipBreak()
                    }, label: {
                        Text("Skip")
                            .padding(.vertical, 2)
                            .frame(maxWidth: .infinity)
                    })
                }
                .frame(minWidth: 150)
            }
            .padding(.vertical, 10)

            HStack {
                Text("Session:")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("25", value: $vm.minsSession, format: .number)
                    .focusable(isFieldFocusable)
                    .focused($isFieldFocused)
                    .onSubmit { isFieldFocused = false }
                    .frame(width: 30)
                    .multilineTextAlignment(.trailing)
                Text("min")
            }

            HStack {
                Text("Break:")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("5", value: $vm.minsBreak, format: .number)
                    .focusable(isFieldFocusable)
                    .focused($isFieldFocused)
                    .onSubmit { isFieldFocused = false }
                    .frame(width: 30)
                    .multilineTextAlignment(.trailing)
                Text("min")
            }
            .padding(.bottom)

            Text("Completed \(vm.stats.totalSessions) sessions")
                .opacity(0.7)
                .padding(.bottom, 5)

            Text("\((Int(vm.stats.totalSeconds) / 3600) > 0 ? "\(Int(vm.stats.totalSeconds) / 3600) hr " : "")\((Int(vm.stats.totalSeconds) / 60 % 60) > 0 ? "\(Int(vm.stats.totalSeconds) / 60 % 60) min " : "0 min ")total")
                .opacity(0.7)
        }
        .padding(30)
        .contentShape(.rect)
        .fixedSize(horizontal: true, vertical: false)
        .onTapGesture {
            isFieldFocused = false
        }
        .onAppear {
            // workaround to stop input fields from being focused automatically
            DispatchQueue.main.async {
                isFieldFocusable = true
            }
        }
    }

    private func formatTime(sec: TimeInterval) -> String {
        let minutes = Int(sec) / 60
        let seconds = Int(sec) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    TimerView()
}
