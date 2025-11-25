//
//  CuzdanTakipApp.swift
//  CuzdanTakip
//
//  Premium Finance Tracking App - Cüzdan Takip v2
//

import SwiftUI
import UserNotifications

@main
struct CuzdanTakipApp: App {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showNotificationPermission = false

    init() {
        // Bildirim delegate'ini ayarla
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
                .environmentObject(notificationManager)
                .preferredColorScheme(nil) // Otomatik dark/light mode
                .onAppear {
                    // Bildirim izni kontrolü
                    checkNotificationPermission()
                }
                .sheet(isPresented: $showNotificationPermission) {
                    NotificationPermissionView()
                }
        }
    }

    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .notDetermined {
                    // İlk kez açılış, izin iste
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showNotificationPermission = true
                    }
                }
            }
        }
    }
}

// Bildirim delegate
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    // Uygulama açıkken gelen bildirimler
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    // Bildirime tıklanınca
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        if let transactionId = userInfo["transactionId"] as? String {
            print("Bildirime tıklandı: \(transactionId)")
            // TODO: İşlem detayını aç
        }

        completionHandler()
    }
}
