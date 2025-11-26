//
//  NotificationManager.swift
//  FinanceTracker
//
//  Bildirim yönetimi - Gelecek ödemeler için hatırlatıcılar
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false

    private init() {
        checkAuthorization()
    }

    // Bildirim izni kontrolü
    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    // Bildirim izni iste
    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])

            DispatchQueue.main.async {
                self.isAuthorized = granted
            }

            return granted
        } catch {
            print("Bildirim izni hatası: \(error.localizedDescription)")
            return false
        }
    }

    // Tüm bildirimleri temizle
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    // Gelecek ödemeler için bildirim planla
    func scheduleNotifications(for transactions: [Transaction]) {
        // Önce mevcut bildirimleri temizle
        clearAllNotifications()

        guard isAuthorized else {
            print("Bildirim izni verilmemiş")
            return
        }

        let calendar = Calendar.current
        let now = Date()

        for transaction in transactions {
            guard let dueDate = transaction.dueDate, !transaction.isPaid else {
                continue
            }

            // Sadece gelecekteki tarihlere bildirim oluştur
            guard dueDate > now else { continue }

            // 3 farklı bildirim zamanı: 3 gün önce, 1 gün önce, ödeme günü
            scheduleNotification(
                for: transaction,
                on: dueDate,
                daysBefore: 3,
                title: "Yaklaşan Ödeme",
                body: "\(transaction.title) - 3 gün içinde: \(transaction.amount.toCurrency())"
            )

            scheduleNotification(
                for: transaction,
                on: dueDate,
                daysBefore: 1,
                title: "Yarın Ödeme Var!",
                body: "\(transaction.title) - \(transaction.amount.toCurrency())"
            )

            scheduleNotification(
                for: transaction,
                on: dueDate,
                daysBefore: 0,
                title: "Bugün Ödeme Günü!",
                body: "\(transaction.title) - \(transaction.amount.toCurrency()) ödenmeli"
            )
        }
    }

    // Belirli bir işlem için bildirim planla
    private func scheduleNotification(
        for transaction: Transaction,
        on dueDate: Date,
        daysBefore days: Int,
        title: String,
        body: String
    ) {
        let calendar = Calendar.current
        guard let notificationDate = calendar.date(byAdding: .day, value: -days, to: dueDate) else {
            return
        }

        // Geçmiş tarihlere bildirim oluşturma
        guard notificationDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1

        // Kategori bilgisi ekle
        content.categoryIdentifier = "PAYMENT_REMINDER"
        content.userInfo = [
            "transactionId": transaction.id.uuidString,
            "amount": transaction.amount,
            "type": transaction.type.rawValue
        ]

        // Bildirim zamanını ayarla (sabah 9:00)
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: notificationDate)
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        // Benzersiz identifier oluştur
        let identifier = "\(transaction.id.uuidString)-\(days)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Bildirim ekleme hatası: \(error.localizedDescription)")
            } else {
                print("Bildirim planlandı: \(title) - \(notificationDate)")
            }
        }
    }

    // Acil ödemeler için anında bildirim
    func sendImmediateNotification(for transaction: Transaction) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Acil Ödeme!"
        content.body = "\(transaction.title) - \(transaction.amount.toCurrency()) bugün ödenmeli!"
        content.sound = .defaultCritical
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // Planlanmış bildirimleri listele (debug için)
    func printPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("📬 Planlanmış bildirimler: \(requests.count)")
            for request in requests {
                print("- \(request.content.title): \(request.content.body)")
            }
        }
    }
}

// Bildirim izin görünümü
struct NotificationPermissionView: View {
    @ObservedObject var notificationManager = NotificationManager.shared
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // İkon
                ZStack {
                    Circle()
                        .fill(Theme.primaryGradient.opacity(0.2))
                        .frame(width: 120, height: 120)

                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(Theme.primaryGradient)
                }
                .padding(.top, 40)

                // Açıklama
                VStack(spacing: 16) {
                    Text("Ödeme Hatırlatıcıları")
                        .font(Theme.title)
                        .fontWeight(.bold)

                    Text("Yaklaşan ödemelerinizi kaçırmayın! Bildirim izni vererek:")
                        .font(Theme.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)

                    VStack(alignment: .leading, spacing: 12) {
                        FeatureRow(
                            icon: "calendar.badge.clock",
                            text: "3 gün önceden hatırlatma"
                        )
                        FeatureRow(
                            icon: "clock.badge.exclamationmark",
                            text: "1 gün önceden hatırlatma"
                        )
                        FeatureRow(
                            icon: "bell.badge.fill",
                            text: "Ödeme günü hatırlatması"
                        )
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                }

                Spacer()

                // Butonlar
                VStack(spacing: 12) {
                    Button(action: {
                        Task {
                            await notificationManager.requestAuthorization()
                            dismiss()
                        }
                    }) {
                        Text("Bildirimlere İzin Ver")
                            .font(Theme.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.primaryGradient)
                            .cornerRadius(15)
                    }

                    Button(action: {
                        dismiss()
                    }) {
                        Text("Daha Sonra")
                            .font(Theme.callout)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Theme.primaryGradient)
                .frame(width: 30)

            Text(text)
                .font(Theme.body)
                .foregroundColor(.primary)

            Spacer()
        }
    }
}

#Preview {
    NotificationPermissionView()
}
