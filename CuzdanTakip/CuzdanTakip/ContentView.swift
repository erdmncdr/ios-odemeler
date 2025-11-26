//
//  ContentView.swift
//  FinanceTracker
//
//  Ana görünüm - Tab Navigation
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .expenses
    @State private var showingSettings = false
    @State private var showingAnalytics = false
    @Environment(\.colorScheme) var colorScheme

    enum Tab: String, CaseIterable {
        case expenses = "Giderler"
        case income = "Gelirler"
        case debts = "Borçlar"
        case upcoming = "Ödemeler"

        var icon: String {
            switch self {
            case .expenses: return "cart.fill"
            case .income: return "banknote.fill"
            case .debts: return "creditcard.fill"
            case .upcoming: return "calendar.badge.clock"
            }
        }

        var gradient: LinearGradient {
            switch self {
            case .expenses: return Theme.accentGradient
            case .income: return Theme.successGradient
            case .debts: return LinearGradient(
                colors: [.orange, .red],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            case .upcoming: return Theme.primaryGradient
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Arka plan gradient
                Theme.backgroundGradient(colorScheme)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Ana içerik
                    TabView(selection: $selectedTab) {
                        ExpensesView()
                            .tag(Tab.expenses)

                        IncomeView()
                            .tag(Tab.income)

                        DebtsView()
                            .tag(Tab.debts)

                        UpcomingPaymentsView()
                            .tag(Tab.upcoming)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    // Custom Bottom Navigation
                    CustomTabBar(selectedTab: $selectedTab)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                        .padding(.top, 5)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedTab)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Cüzdan Takip")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        // Analitik butonu
                        Button {
                            HapticManager.shared.impact(style: .light)
                            showingAnalytics = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 36, height: 36)

                                Image(systemName: "chart.pie.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.purple)
                            }
                        }

                        // Ayarlar butonu
                        Button {
                            HapticManager.shared.impact(style: .light)
                            showingSettings = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 36, height: 36)

                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingAnalytics) {
                AnalyticsView()
            }
        }
    }
}

// Özel Tab Bar - Premium Liquid Glass
struct CustomTabBar: View {
    @Binding var selectedTab: ContentView.Tab
    @Environment(\.colorScheme) var colorScheme
    @Namespace private var animation
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ContentView.Tab.allCases, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    namespace: animation
                ) {
                    guard !isAnimating else { return }
                    HapticManager.shared.selection()
                    isAnimating = true
                    selectedTab = tab

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isAnimating = false
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            ZStack {
                // Premium liquid glass effect
                RoundedRectangle(cornerRadius: 30)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(colorScheme == .dark ? 0.15 : 0.3),
                                        Color.white.opacity(colorScheme == .dark ? 0.05 : 0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(colorScheme == .dark ? 0.3 : 0.6),
                                        Color.white.opacity(colorScheme == .dark ? 0.1 : 0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(
                        color: colorScheme == .dark
                            ? Color.black.opacity(0.5)
                            : Color.black.opacity(0.15),
                        radius: 20,
                        x: 0,
                        y: 10
                    )
            }
        )
    }
}

// Tab Bar butonu
struct TabBarButton: View {
    let tab: ContentView.Tab
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(tab.gradient)
                            .frame(width: 50, height: 50)
                            .matchedGeometryEffect(
                                id: "TAB_BACKGROUND",
                                in: namespace,
                                properties: .frame,
                                anchor: .center,
                                isSource: true
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                            .transition(.scale.combined(with: .opacity))
                    }

                    Image(systemName: tab.icon)
                        .font(.system(size: 22, weight: isSelected ? .bold : .regular))
                        .foregroundColor(isSelected ? .white : .secondary)
                        .animation(.easeInOut(duration: 0.2), value: isSelected)
                }

                Text(tab.rawValue)
                    .font(Theme.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
        .environmentObject(DataManager.shared)
}
