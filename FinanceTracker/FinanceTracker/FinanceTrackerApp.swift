//
//  FinanceTrackerApp.swift
//  FinanceTracker
//
//  Premium Finance Tracking App
//

import SwiftUI

@main
struct FinanceTrackerApp: App {
    @StateObject private var dataManager = DataManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
                .preferredColorScheme(nil) // Otomatik dark/light mode
        }
    }
}
