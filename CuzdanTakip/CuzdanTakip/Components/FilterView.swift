//
//  FilterView.swift
//  CuzdanTakip
//
//  Akıllı filtreleme komponenti
//

import SwiftUI

struct FilterView: View {
    @Binding var filterOptions: FilterOptions
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    @State private var selectedDateRange: DateRange?
    @State private var selectedCategories: Set<TransactionCategory> = []
    @State private var selectedTypes: Set<TransactionType> = []
    @State private var minAmountText = ""
    @State private var maxAmountText = ""
    @State private var isPaidFilter: Int = 0 // 0: Tümü, 1: Ödendi, 2: Ödenmedi

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient(colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Tarih Aralığı
                        FilterSection(title: "Tarih Aralığı", icon: "calendar") {
                            VStack(spacing: 12) {
                                ForEach([DateRange.today, .thisWeek, .thisMonth, .last30Days, .last3Months, .thisYear], id: \.title) { range in
                                    FilterChip(
                                        title: range.title,
                                        isSelected: selectedDateRange?.title == range.title
                                    ) {
                                        HapticManager.shared.selection()
                                        selectedDateRange = selectedDateRange?.title == range.title ? nil : range
                                    }
                                }
                            }
                        }

                        // Kategoriler
                        FilterSection(title: "Kategoriler", icon: "folder") {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                                ForEach(TransactionCategory.allCases, id: \.self) { category in
                                    FilterChip(
                                        title: category.rawValue,
                                        icon: category.icon,
                                        isSelected: selectedCategories.contains(category)
                                    ) {
                                        HapticManager.shared.selection()
                                        if selectedCategories.contains(category) {
                                            selectedCategories.remove(category)
                                        } else {
                                            selectedCategories.insert(category)
                                        }
                                    }
                                }
                            }
                        }

                        // İşlem Tipi
                        FilterSection(title: "İşlem Tipi", icon: "arrow.left.arrow.right") {
                            VStack(spacing: 12) {
                                ForEach(TransactionType.allCases, id: \.self) { type in
                                    FilterChip(
                                        title: type.rawValue,
                                        isSelected: selectedTypes.contains(type)
                                    ) {
                                        HapticManager.shared.selection()
                                        if selectedTypes.contains(type) {
                                            selectedTypes.remove(type)
                                        } else {
                                            selectedTypes.insert(type)
                                        }
                                    }
                                }
                            }
                        }

                        // Miktar Aralığı
                        FilterSection(title: "Miktar Aralığı", icon: "turkishlirasign.circle") {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Min")
                                        .font(Theme.caption)
                                        .foregroundColor(.secondary)
                                    TextField("0", text: $minAmountText)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(.plain)
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.gray.opacity(0.1))
                                        )
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Max")
                                        .font(Theme.caption)
                                        .foregroundColor(.secondary)
                                    TextField("∞", text: $maxAmountText)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(.plain)
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.gray.opacity(0.1))
                                        )
                                }
                            }
                        }

                        // Durum
                        FilterSection(title: "Ödeme Durumu", icon: "checkmark.circle") {
                            Picker("", selection: $isPaidFilter) {
                                Text("Tümü").tag(0)
                                Text("Ödendi").tag(1)
                                Text("Ödenmedi").tag(2)
                            }
                            .pickerStyle(.segmented)
                        }

                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
            .navigationTitle("Filtreler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        HapticManager.shared.impact(style: .light)
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button("Sıfırla") {
                        HapticManager.shared.impact(style: .medium)
                        resetFilters()
                    }
                    .disabled(!hasActiveFilters)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Uygula") {
                        HapticManager.shared.success()
                        applyFilters()
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadCurrentFilters()
            }
        }
    }

    private var hasActiveFilters: Bool {
        selectedDateRange != nil ||
        !selectedCategories.isEmpty ||
        !selectedTypes.isEmpty ||
        !minAmountText.isEmpty ||
        !maxAmountText.isEmpty ||
        isPaidFilter != 0
    }

    private func loadCurrentFilters() {
        selectedDateRange = filterOptions.dateRange
        selectedCategories = filterOptions.categories
        selectedTypes = filterOptions.types
        minAmountText = filterOptions.minAmount.map { String($0) } ?? ""
        maxAmountText = filterOptions.maxAmount.map { String($0) } ?? ""

        if let isPaid = filterOptions.isPaid {
            isPaidFilter = isPaid ? 1 : 2
        } else {
            isPaidFilter = 0
        }
    }

    private func applyFilters() {
        filterOptions.dateRange = selectedDateRange
        filterOptions.categories = selectedCategories
        filterOptions.types = selectedTypes
        filterOptions.minAmount = Double(minAmountText.replacingOccurrences(of: ",", with: "."))
        filterOptions.maxAmount = Double(maxAmountText.replacingOccurrences(of: ",", with: "."))
        filterOptions.isPaid = isPaidFilter == 0 ? nil : (isPaidFilter == 1)
    }

    private func resetFilters() {
        selectedDateRange = nil
        selectedCategories.removeAll()
        selectedTypes.removeAll()
        minAmountText = ""
        maxAmountText = ""
        isPaidFilter = 0
    }
}

// Filter Section
struct FilterSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content

    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                Text(title)
                    .font(Theme.headline)
                    .fontWeight(.semibold)
            }

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .premiumCard()
    }
}

// Filter Chip
struct FilterChip: View {
    let title: String
    var icon: String?
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                }
                Text(title)
                    .font(Theme.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Theme.primaryGradient : (colorScheme == .dark ? Color.white.opacity(0.1) : Color.gray.opacity(0.1)))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    FilterView(filterOptions: .constant(FilterOptions()))
}
