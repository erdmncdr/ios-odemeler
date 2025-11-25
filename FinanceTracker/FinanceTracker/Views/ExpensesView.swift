//
//  ExpensesView.swift
//  FinanceTracker
//
//  Giderler ekranı
//

import SwiftUI

struct ExpensesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddSheet = false
    @State private var selectedTransaction: Transaction?
    @Environment(\.colorScheme) var colorScheme

    private var expenses: [Transaction] {
        dataManager.getTransactions(ofType: .expense)
    }

    private var todayExpenses: [Transaction] {
        dataManager.getTodayTransactions().filter { $0.type == .expense }
    }

    private var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    private var todayTotal: Double {
        todayExpenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Başlık
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Giderler")
                                .font(Theme.largeTitle)
                                .fontWeight(.bold)

                            Text("Harcamalarınızı takip edin")
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
                            title: "Toplam Gider",
                            amount: totalExpenses,
                            icon: "cart.fill",
                            gradient: Theme.accentGradient
                        )

                        SummaryCard(
                            title: "Bugün",
                            amount: todayTotal,
                            icon: "calendar",
                            gradient: Theme.primaryGradient
                        )
                    }
                    .padding(.horizontal)

                    // Bugünün giderleri
                    if !todayExpenses.isEmpty {
                        VStack(spacing: 12) {
                            SectionHeader("Bugün", icon: "star.fill")

                            ForEach(todayExpenses) { transaction in
                                TransactionCard(transaction: transaction)
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

                    // Tüm giderler
                    if !expenses.isEmpty {
                        VStack(spacing: 12) {
                            SectionHeader("Tüm Giderler", icon: "list.bullet")

                            ForEach(expenses) { transaction in
                                TransactionCard(transaction: transaction)
                                    .padding(.horizontal)
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
                    } else {
                        EmptyStateView(
                            icon: "cart",
                            title: "Henüz gider yok",
                            message: "Harcamalarınızı kaydetmeye başlayın"
                        )
                        .padding(.top, 60)
                    }

                    Spacer(minLength: 100)
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddTransactionView(transactionType: .expense)
        }
        .sheet(item: $selectedTransaction) { transaction in
            TransactionDetailView(transaction: transaction)
        }
    }
}

// Yeni işlem ekleme ekranı
struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager

    let transactionType: TransactionType

    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory: TransactionCategory = .other
    @State private var date = Date()
    @State private var note = ""
    @State private var hasDueDate = false
    @State private var dueDate = Date()

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient(.light)
                    .ignoresSafeArea()

                Form {
                    Section("Bilgiler") {
                        TextField("Başlık", text: $title)
                        TextField("Miktar", text: $amount)
                            .keyboardType(.decimalPad)

                        Picker("Kategori", selection: $selectedCategory) {
                            ForEach(TransactionCategory.allCases, id: \.self) { category in
                                Label(category.rawValue, systemImage: category.icon)
                                    .tag(category)
                            }
                        }

                        DatePicker("Tarih", selection: $date, displayedComponents: .date)
                    }

                    if transactionType == .debt || transactionType == .upcoming {
                        Section("Son Ödeme Tarihi") {
                            Toggle("Son ödeme tarihi var", isOn: $hasDueDate)

                            if hasDueDate {
                                DatePicker("Son tarih", selection: $dueDate, displayedComponents: .date)
                            }
                        }
                    }

                    Section("Not (Opsiyonel)") {
                        TextEditor(text: $note)
                            .frame(height: 100)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Yeni \(transactionType.rawValue)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        saveTransaction()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private var isValid: Bool {
        !title.isEmpty && !amount.isEmpty && Double(amount.replacingOccurrences(of: ",", with: ".")) != nil
    }

    private func saveTransaction() {
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else { return }

        let transaction = Transaction(
            title: title,
            amount: amountValue,
            type: transactionType,
            category: selectedCategory,
            date: date,
            note: note,
            isPaid: transactionType == .expense || transactionType == .income,
            dueDate: hasDueDate ? dueDate : nil
        )

        dataManager.addTransaction(transaction)
        dismiss()
    }
}

// İşlem detay ekranı
struct TransactionDetailView: View {
    let transaction: Transaction
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient(.light)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // İkon ve miktar
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(transaction.category.color.opacity(0.2))
                                    .frame(width: 100, height: 100)

                                Image(systemName: transaction.category.icon)
                                    .font(.system(size: 40))
                                    .foregroundColor(transaction.category.color)
                            }

                            Text(transaction.amount.toCurrency())
                                .font(Theme.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(
                                    transaction.type == .income
                                        ? Theme.successGradient
                                        : Theme.accentGradient
                                )
                        }
                        .padding(.top, 30)

                        // Bilgiler
                        VStack(spacing: 16) {
                            DetailRow(icon: "tag.fill", title: "Başlık", value: transaction.title)
                            DetailRow(icon: "folder.fill", title: "Kategori", value: transaction.category.rawValue)
                            DetailRow(icon: "calendar", title: "Tarih", value: transaction.date.toShortString())

                            if let dueDate = transaction.dueDate {
                                DetailRow(icon: "clock.fill", title: "Son Tarih", value: dueDate.toShortString())
                            }

                            if !transaction.note.isEmpty {
                                DetailRow(icon: "note.text", title: "Not", value: transaction.note)
                            }

                            DetailRow(
                                icon: transaction.isPaid ? "checkmark.circle.fill" : "xmark.circle.fill",
                                title: "Durum",
                                value: transaction.isPaid ? "Ödendi" : "Ödenmedi"
                            )
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle(transaction.type.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .destructiveAction) {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
            .alert("Silmek istediğinizden emin misiniz?", isPresented: $showingDeleteAlert) {
                Button("İptal", role: .cancel) { }
                Button("Sil", role: .destructive) {
                    dataManager.deleteTransaction(transaction)
                    dismiss()
                }
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.secondary)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.caption)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(Theme.body)
                    .foregroundColor(.primary)
            }

            Spacer()
        }
        .padding()
        .premiumCard()
    }
}

#Preview {
    ExpensesView()
        .environmentObject(DataManager.shared)
}
