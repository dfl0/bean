//
//  beanApp.swift
//  bean
//
//  Created by dorin flocos on 11/3/24.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidBecomeActive(_ notification: Notification) {
        NSApp.windows.first?.level = .normal
    }
}

@main
struct beanApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            TimerView()
        }
    }
}
