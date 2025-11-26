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
    @StateObject private var biometricAuth = BiometricAuthManager.shared
    @StateObject private var appearanceManager = AppearanceManager.shared
    @State private var showNotificationPermission = false
    @Environment(\.scenePhase) var scenePhase

    init() {
        // Bildirim delegate'ini ayarla
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(dataManager)
                    .environmentObject(notificationManager)
                    .environmentObject(biometricAuth)
                    .environmentObject(appearanceManager)
                    .preferredColorScheme(appearanceManager.colorScheme)
                    .onAppear {
                        // Bildirim izni kontrolü
                        checkNotificationPermission()
                    }
                    .sheet(isPresented: $showNotificationPermission) {
                        NotificationPermissionView()
                    }

                // Kilit ekranı overlay
                if biometricAuth.isLocked && biometricAuth.isBiometricEnabled {
                    LockScreenView()
                        .environmentObject(biometricAuth)
                        .transition(.opacity)
                        .zIndex(999)
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                switch newPhase {
                case .background:
                    // Uygulama arka plana geçtiğinde kilitle
                    biometricAuth.lockApp()
                case .active:
                    // Uygulama aktif olduğunda tekrarlayan işlemleri kontrol et
                    dataManager.generateRecurringTransactions()
                case .inactive:
                    break
                @unknown default:
                    break
                }
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
