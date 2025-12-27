//
//  TransactionHistoryView.swift
//  PaymentSystem
//
//  Created by Ahmad Tamim Dostyar on 12/26/25.
//

import SwiftUI

struct TransactionHistoryView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @StateObject private var viewModel = TransactionViewModel()
    @State private var selectedFilter: TransactionFilter = .all
    
    var userID: Int {
        loginViewModel.currentUser?.userID ?? 1
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Stats
            headerStats
            
            // Filter Pills
            filterPills
            
            // Transaction List
            transactionList
        }
        .background(Color(hex: "0d0d0d").ignoresSafeArea())
        .navigationTitle("Transactions")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color(hex: "0d0d0d"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.fetchTransactions(userID: userID)
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(Color(hex: "a78bfa"))
                }
            }
        }
        .onAppear {
            viewModel.fetchTransactions(userID: userID)
        }
    }
    
    // MARK: - Header Stats
    private var headerStats: some View {
        HStack(spacing: 16) {
            statCard(
                title: "Total",
                value: "\(viewModel.transactions.count)",
                icon: "list.bullet.rectangle",
                color: Color(hex: "a78bfa")
            )
            
            statCard(
                title: "Credits",
                value: "\(viewModel.transactions.filter { $0.type.uppercased() == "CREDIT" }.count)",
                icon: "arrow.down.circle.fill",
                color: Color(hex: "34d399")
            )
            
            statCard(
                title: "Debits",
                value: "\(viewModel.transactions.filter { $0.type.uppercased() == "DEBIT" }.count)",
                icon: "arrow.up.circle.fill",
                color: Color(hex: "f87171")
            )
        }
        .padding(20)
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
        )
    }
    
    // MARK: - Filter Pills
    private var filterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TransactionFilter.allCases, id: \.self) { filter in
                    filterPill(filter)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
    }
    
    private func filterPill(_ filter: TransactionFilter) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedFilter = filter
            }
        } label: {
            Text(filter.displayName)
                .font(.subheadline.bold())
                .foregroundColor(selectedFilter == filter ? .black : .white.opacity(0.7))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(selectedFilter == filter ? filter.color : .white.opacity(0.1))
                )
        }
    }
    
    // MARK: - Transaction List
    private var transactionList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if viewModel.isLoading {
                    loadingView
                } else if filteredTransactions.isEmpty {
                    emptyView
                } else {
                    ForEach(filteredTransactions) { transaction in
                        transactionRow(transaction)
                    }
                }
            }
            .padding(20)
        }
    }
    
    private var filteredTransactions: [TransactionItem] {
        switch selectedFilter {
        case .all:
            return viewModel.transactions
        case .credit:
            return viewModel.transactions.filter { $0.type.uppercased() == "CREDIT" }
        case .debit:
            return viewModel.transactions.filter { $0.type.uppercased() == "DEBIT" }
        case .transfer:
            return viewModel.transactions.filter { $0.type.uppercased() == "TRANSFER" }
        case .pending:
            return viewModel.transactions.filter { $0.status.uppercased() == "PENDING" }
        }
    }
    
    // MARK: - Transaction Row
    private func transactionRow(_ transaction: TransactionItem) -> some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(typeColor(transaction.type).opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: typeIcon(transaction.type))
                    .font(.system(size: 20))
                    .foregroundColor(typeColor(transaction.type))
            }
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description.isEmpty ? "Transaction" : transaction.description)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(transaction.date.isEmpty ? "Today" : transaction.date)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                    
                    if !transaction.status.isEmpty {
                        statusBadge(transaction.status)
                    }
                }
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatAmount(transaction.amount, type: transaction.type))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(transaction.type.uppercased() == "CREDIT" ? Color(hex: "34d399") : Color(hex: "f87171"))
                
                Text(transaction.type.capitalized)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
    
    private func statusBadge(_ status: String) -> some View {
        Text(status.capitalized)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(statusColor(status))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(statusColor(status).opacity(0.2))
            )
    }
    
    private func typeIcon(_ type: String) -> String {
        switch type.uppercased() {
        case "CREDIT":
            return "arrow.down.left"
        case "DEBIT":
            return "arrow.up.right"
        case "TRANSFER":
            return "arrow.left.arrow.right"
        default:
            return "dollarsign.circle"
        }
    }
    
    private func typeColor(_ type: String) -> Color {
        switch type.uppercased() {
        case "CREDIT":
            return Color(hex: "34d399")
        case "DEBIT":
            return Color(hex: "f87171")
        case "TRANSFER":
            return Color(hex: "60a5fa")
        default:
            return Color(hex: "a78bfa")
        }
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status.uppercased() {
        case "COMPLETE":
            return Color(hex: "34d399")
        case "PENDING":
            return Color(hex: "fbbf24")
        case "FAIL":
            return Color(hex: "f87171")
        default:
            return .gray
        }
    }
    
    private func formatAmount(_ amount: Int, type: String) -> String {
        let prefix = type.uppercased() == "CREDIT" ? "+" : "-"
        return "\(prefix)$\(amount)"
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "a78bfa")))
                .scaleEffect(1.5)
            
            Text("Loading transactions...")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color(hex: "a78bfa").opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: "a78bfa"))
            }
            
            Text("No Transactions")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Text("Your transaction history will appear here")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Transaction Filter
enum TransactionFilter: CaseIterable {
    case all, credit, debit, transfer, pending
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .credit: return "Credits"
        case .debit: return "Debits"
        case .transfer: return "Transfers"
        case .pending: return "Pending"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return Color(hex: "a78bfa")
        case .credit: return Color(hex: "34d399")
        case .debit: return Color(hex: "f87171")
        case .transfer: return Color(hex: "60a5fa")
        case .pending: return Color(hex: "fbbf24")
        }
    }
}

#Preview {
    NavigationStack {
        TransactionHistoryView()
    }
}

