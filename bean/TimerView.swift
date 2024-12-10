//
//  TimerView.swift
//  bean
//
//  Created by dorin flocos on 12/8/24.
//

import SwiftUI

struct TimerView: View {
    @State private var vm = TimerViewModel()
    @FocusState private var isFieldFocused: Bool

    var body: some View {
        VStack {
            Text(!vm.sessionComplete ? "Session" : "Break")
                .opacity(0.7)

            Text(formatTime(sec: vm.elapsedTime))
                .font(.largeTitle)
                .padding(.vertical, 5)

            Text("[\(vm.speed.formatted())x as fast]")
                .opacity(0.7)
                .hidden(vm.speed == 1)

            VStack {
                HStack {
                    !vm.running
                    ? Button(action: vm.startTimer, label: { Text("Start").frame(maxWidth: .infinity) })
                    : Button(action: vm.pauseTimer, label: { Text("Pause").frame(maxWidth: .infinity) })

                    !vm.sessionComplete
                    ? Button(action: vm.resetTimer, label: { Text("Reset").frame(maxWidth: .infinity) })
                    : Button(action: vm.skipBreak, label: { Text("Skip").frame(maxWidth: .infinity) })
                }
                .frame(minWidth: 150)
            }
            .padding(.bottom)

            HStack {
                Text("Session:")
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("25", value: $vm.minsSession, format: .number)
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
