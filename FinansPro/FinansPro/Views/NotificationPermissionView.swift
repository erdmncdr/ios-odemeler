//
//  NotificationPermissionView.swift
//  FinansPro
//
//  Bildirim izni isteme ekranı
//

import SwiftUI
import UserNotifications

struct NotificationPermissionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var isRequesting = false

    var body: some View {
        ZStack {
            // Gradient arka plan
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // İkon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 120, height: 120)

                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                }

                // Başlık ve açıklama
                VStack(spacing: 16) {
                    Text("Bildirimler")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)

                    Text("Yaklaşan ödeme ve son ödeme tarihlerini kaçırmayın")
                        .font(Theme.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                // Özellikler
                VStack(alignment: .leading, spacing: 20) {
                    PermissionFeature(
                        icon: "calendar.badge.clock",
                        title: "Ödeme Hatırlatıcıları",
                        description: "Son ödeme tarihinden önce bildirim al"
                    )

                    PermissionFeature(
                        icon: "creditcard.fill",
                        title: "Borç Takibi",
                        description: "Ödenmemiş borçlarını takip et"
                    )

                    PermissionFeature(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Harcama Özeti",
                        description: "Haftalık ve aylık harcama özeti"
                    )
                }
                .padding(.horizontal, 30)

                Spacer()

                // Butonlar
                VStack(spacing: 12) {
                    // İzin ver butonu
                    Button(action: requestPermission) {
                        HStack {
                            if isRequesting {
                                ProgressView()
                                    .tint(.blue)
                            } else {
                                Text("Bildirimlere İzin Ver")
                                    .fontWeight(.semibold)
                            }
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                    }
                    .disabled(isRequesting)

                    // Şimdilik atla
                    Button(action: {
                        HapticManager.shared.impact(style: .light)
                        dismiss()
                    }) {
                        Text("Şimdilik Atla")
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }

    private func requestPermission() {
        isRequesting = true
        HapticManager.shared.impact(style: .medium)

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                isRequesting = false

                if granted {
                    HapticManager.shared.success()
                    notificationManager.requestPermission()
                } else {
                    HapticManager.shared.warning()
                }

                // Kısa bir gecikme sonra kapat
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            }
        }
    }
}

struct PermissionFeature: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.headline)
                    .foregroundColor(.white)

                Text(description)
                    .font(Theme.caption)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()
        }
    }
}

#Preview {
    NotificationPermissionView()
        .environmentObject(NotificationManager.shared)
}
