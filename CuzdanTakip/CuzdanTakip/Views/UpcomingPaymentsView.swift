//
//  UpcomingPaymentsView.swift
//  FinanceTracker
//
//  Gelecek ödemeler ekranı
//

import SwiftUI

struct UpcomingPaymentsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddSheet = false
    @State private var selectedTransaction: Transaction?
    @State private var searchText = ""
    @State private var filterOptions = FilterOptions()
    @State private var showingFilterSheet = false
    @Environment(\.colorScheme) var colorScheme

    private var upcomingPayments: [Transaction] {
        let allUpcoming = dataManager.getUpcomingPayments()

        // Filtre aktifse filtrele, değilse sadece arama yap
        if filterOptions.isActive {
            // Gelecek ödemeler için filtre
            let lowercasedQuery = searchText.lowercased()
            var result = allUpcoming

            // Arama
            if !searchText.isEmpty {
                result = result.filter { transaction in
                    transaction.title.lowercased().contains(lowercasedQuery) ||
                    transaction.note.lowercased().contains(lowercasedQuery) ||
                    transaction.category.rawValue.lowercased().contains(lowercasedQuery)
                }
            }

            // Kategori filtresi
            if !filterOptions.categories.isEmpty {
                result = result.filter { filterOptions.categories.contains($0.category) }
            }

            // Miktar filtresi
            if let minAmount = filterOptions.minAmount {
                result = result.filter { $0.amount >= minAmount }
            }
            if let maxAmount = filterOptions.maxAmount {
                result = result.filter { $0.amount <= maxAmount }
            }

            return result
        } else if !searchText.isEmpty {
            let lowercasedQuery = searchText.lowercased()
            return allUpcoming.filter { transaction in
                transaction.title.lowercased().contains(lowercasedQuery) ||
                transaction.note.lowercased().contains(lowercasedQuery) ||
                transaction.category.rawValue.lowercased().contains(lowercasedQuery)
            }
        } else {
            return allUpcoming
        }
    }

    private var totalUpcoming: Double {
        upcomingPayments.reduce(0) { $0 + $1.amount }
    }

    private var thisWeekPayments: [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        let weekFromNow = calendar.date(byAdding: .day, value: 7, to: now) ?? now

        return upcomingPayments.filter { transaction in
            guard let dueDate = transaction.dueDate else { return false }
            return dueDate >= now && dueDate <= weekFromNow
        }
    }

    private var thisWeekTotal: Double {
        thisWeekPayments.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Başlık
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Gelecek Ödemeler")
                                .font(Theme.largeTitle)
                                .fontWeight(.bold)

                            Text("Yaklaşan ödemeleriniz")
                                .font(Theme.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        // Filtre butonu
                        Button {
                            HapticManager.shared.impact(style: .light)
                            showingFilterSheet = true
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(Theme.primaryGradient)

                                // Aktif filtre göstergesi
                                if filterOptions.isActive {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 10, height: 10)
                                        .offset(x: 2, y: -2)
                                }
                            }
                        }
                        .padding(.trailing, 8)

                        AddTransactionButton {
                            HapticManager.shared.impact(style: .medium)
                            showingAddSheet = true
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)

                    // Arama çubuğu
                    SearchBar(text: $searchText, placeholder: "Ödeme ara...")
                        .padding(.horizontal)

                    // Özet kartları
                    HStack(spacing: 15) {
                        SummaryCard(
                            title: "Toplam",
                            amount: totalUpcoming,
                            icon: "calendar.badge.clock",
                            gradient: Theme.primaryGradient
                        )

                        SummaryCard(
                            title: "Bu Hafta",
                            amount: thisWeekTotal,
                            icon: "calendar.badge.exclamationmark",
                            gradient: LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    }
                    .padding(.horizontal)

                    // Bu haftaki ödemeler
                    if !thisWeekPayments.isEmpty {
                        VStack(spacing: 12) {
                            SectionHeader("Bu Hafta", icon: "exclamationmark.triangle.fill")

                            ForEach(thisWeekPayments) { transaction in
                                UpcomingPaymentCard(transaction: transaction) {
                                    markAsPaid(transaction)
                                }
                                .padding(.horizontal)
                                .onTapGesture {
                                    HapticManager.shared.impact(style: .light)
                                    selectedTransaction = transaction
                                }
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .opacity
                                ))
                            }
                        }
                    }

                    // Diğer ödemeler
                    let otherPayments = upcomingPayments.filter { !thisWeekPayments.contains($0) }
                    if !otherPayments.isEmpty {
                        VStack(spacing: 12) {
                            SectionHeader("Daha Sonra", icon: "calendar")

                            ForEach(otherPayments) { transaction in
                                UpcomingPaymentCard(transaction: transaction) {
                                    markAsPaid(transaction)
                                }
                                .padding(.horizontal)
                                .onTapGesture {
                                    HapticManager.shared.impact(style: .light)
                                    selectedTransaction = transaction
                                }
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .opacity
                                ))
                            }
                        }
                    }

                    if upcomingPayments.isEmpty {
                        EmptyStateView(
                            icon: "checkmark.circle",
                            title: "Gelecek ödeme yok",
                            message: "Yaklaşan ödemeleriniz burada görünecek"
                        )
                        .padding(.top, 60)
                    }

                    Spacer(minLength: 100)
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddTransactionView(transactionType: .upcoming)
        }
        .sheet(item: $selectedTransaction) { transaction in
            TransactionDetailView(transaction: transaction)
        }
        .sheet(isPresented: $showingFilterSheet) {
            FilterView(filterOptions: $filterOptions)
        }
    }

    private func markAsPaid(_ transaction: Transaction) {
        HapticManager.shared.success()
        var updated = transaction
        updated.isPaid = true
        dataManager.updateTransaction(updated)
    }
}

// Gelecek ödeme kartı
struct UpcomingPaymentCard: View {
    let transaction: Transaction
    let onMarkPaid: () -> Void
    @Environment(\.colorScheme) var colorScheme

    private var daysUntilDue: Int {
        guard let dueDate = transaction.dueDate else { return 0 }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: dueDate)
        return components.day ?? 0
    }

    private var isUrgent: Bool {
        daysUntilDue <= 3 && daysUntilDue >= 0
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 15) {
                // İkon ve gün sayacı
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(isUrgent ? Color.red.opacity(0.2) : transaction.category.color.opacity(0.2))
                            .frame(width: 50, height: 50)

                        if isUrgent {
                            Image(systemName: "exclamationmark")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.red)
                        } else {
                            Image(systemName: transaction.category.icon)
                                .font(.system(size: 22))
                                .foregroundColor(transaction.category.color)
                        }
                    }

                    Text("\(daysUntilDue) gün")
                        .font(Theme.caption)
                        .foregroundColor(isUrgent ? .red : .secondary)
                        .fontWeight(isUrgent ? .bold : .regular)
                }

                // Bilgiler
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.title)
                        .font(Theme.headline)
                        .foregroundColor(.primary)

                    Text(transaction.category.rawValue)
                        .font(Theme.caption)
                        .foregroundColor(.secondary)

                    if let dueDate = transaction.dueDate {
                        Label(dueDate.toShortString(), systemImage: "calendar")
                            .font(Theme.caption)
                            .foregroundColor(isUrgent ? .red : .orange)
                    }
                }

                Spacer()

                // Miktar
                Text(transaction.amount.toCurrency())
                    .font(Theme.headline)
                    .foregroundColor(.red)
                    .fontWeight(.bold)
            }
            .padding()

            // Ödeme butonu
            Button(action: {
                HapticManager.shared.impact(style: .medium)
                onMarkPaid()
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))

                    Text("Ödendi")
                        .font(Theme.callout)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Theme.successGradient)
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isUrgent ? Color.red.opacity(0.6) : Color.clear, lineWidth: isUrgent ? 2 : 0)
        )
        .shadow(
            color: colorScheme == .dark ? Color.black.opacity(0.5) : Color.black.opacity(0.08),
            radius: 15,
            x: 0,
            y: 5
        )
    }
}

#Preview {
    UpcomingPaymentsView()
        .environmentObject(DataManager.shared)
}
