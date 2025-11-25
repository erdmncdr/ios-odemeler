//
//  DebtsView.swift
//  FinanceTracker
//
//  Borçlar ekranı
//

import SwiftUI

struct DebtsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddSheet = false
    @State private var selectedTransaction: Transaction?
    @Environment(\.colorScheme) var colorScheme

    private var debts: [Transaction] {
        dataManager.getTransactions(ofType: .debt)
    }

    private var unpaidDebts: [Transaction] {
        debts.filter { !$0.isPaid }
    }

    private var paidDebts: [Transaction] {
        debts.filter { $0.isPaid }
    }

    private var totalUnpaidDebts: Double {
        unpaidDebts.reduce(0) { $0 + $1.amount }
    }

    private var totalPaidDebts: Double {
        paidDebts.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Başlık
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Borçlar")
                                .font(Theme.largeTitle)
                                .fontWeight(.bold)

                            Text("Borçlarınızı yönetin")
                                .font(Theme.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        AddTransactionButton {
                            showingAddSheet = true
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)

                    // Özet kartları
                    HStack(spacing: 15) {
                        SummaryCard(
                            title: "Ödenmemiş",
                            amount: totalUnpaidDebts,
                            icon: "exclamationmark.triangle.fill",
                            gradient: LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                        SummaryCard(
                            title: "Ödendi",
                            amount: totalPaidDebts,
                            icon: "checkmark.circle.fill",
                            gradient: Theme.successGradient
                        )
                    }
                    .padding(.horizontal)

                    // Ödenmemiş borçlar
                    if !unpaidDebts.isEmpty {
                        VStack(spacing: 12) {
                            SectionHeader("Ödenmesi Gerekenler", icon: "exclamationmark.circle.fill")

                            ForEach(unpaidDebts) { transaction in
                                DebtCard(transaction: transaction) {
                                    markAsPaid(transaction)
                                }
                                .padding(.horizontal)
                                .onTapGesture {
                                    selectedTransaction = transaction
                                }
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .opacity
                                ))
                            }
                        }
                    }

                    // Ödenen borçlar
                    if !paidDebts.isEmpty {
                        VStack(spacing: 12) {
                            SectionHeader("Ödenenler", icon: "checkmark.circle")

                            ForEach(paidDebts) { transaction in
                                TransactionCard(transaction: transaction)
                                    .padding(.horizontal)
                                    .opacity(0.7)
                                    .onTapGesture {
                                        selectedTransaction = transaction
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            withAnimation {
                                                dataManager.deleteTransaction(transaction)
                                            }
                                        } label: {
                                            Label("Sil", systemImage: "trash")
                                        }
                                    }
                                    .transition(.asymmetric(
                                        insertion: .scale.combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            }
                        }
                    }

                    if debts.isEmpty {
                        EmptyStateView(
                            icon: "checkmark.circle",
                            title: "Harika! Borcunuz yok",
                            message: "Finansal durumunuz iyi görünüyor"
                        )
                        .padding(.top, 60)
                    }

                    Spacer(minLength: 100)
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddTransactionView(transactionType: .debt)
        }
        .sheet(item: $selectedTransaction) { transaction in
            TransactionDetailView(transaction: transaction)
        }
    }

    private func markAsPaid(_ transaction: Transaction) {
        var updated = transaction
        updated.isPaid = true
        dataManager.updateTransaction(updated)
    }
}

// Borç kartı - Ödeme butonu ile
struct DebtCard: View {
    let transaction: Transaction
    let onMarkPaid: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 15) {
                // İkon
                ZStack {
                    Circle()
                        .fill(transaction.category.color.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: transaction.category.icon)
                        .font(.system(size: 22))
                        .foregroundColor(transaction.category.color)
                }

                // Bilgiler
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.title)
                        .font(Theme.headline)
                        .foregroundColor(.primary)

                    if let dueDate = transaction.dueDate {
                        Label(dueDate.toRelativeString(), systemImage: "clock.fill")
                            .font(Theme.caption)
                            .foregroundColor(.orange)
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
            Button(action: onMarkPaid) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))

                    Text("Ödendi Olarak İşaretle")
                        .font(Theme.callout)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Theme.successGradient)
            }
        }
        .premiumCard()
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.orange.opacity(0.5), lineWidth: 2)
        )
    }
}

#Preview {
    DebtsView()
        .environmentObject(DataManager.shared)
}
