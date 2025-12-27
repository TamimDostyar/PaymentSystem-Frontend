//
//  HomeView.swift
//  PaymentSystem
//
//  Created by Ahmad Tamim Dostyar on 12/26/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: LoginViewModel
    @StateObject private var transactionViewModel = TransactionViewModel()
    @StateObject private var accountViewModel = AccountViewModel()
    
    @State private var showProfile = false
    
    // Use account balance from API, fallback to transaction calculation
    private var totalBalance: Double {
        if let account = accountViewModel.account {
            return account.amountAvail
        }
        return transactionViewModel.transactions.reduce(0) { sum, transaction in
            sum + Double(transaction.amount)
        }
    }
    
    private var totalIncome: Double {
        transactionViewModel.transactions
            .filter { $0.type.uppercased() == "CREDIT" }
            .reduce(0) { sum, transaction in
                sum + Double(abs(transaction.amount))
            }
    }
    
    private var totalExpenses: Double {
        transactionViewModel.transactions
            .filter { $0.type.uppercased() == "DEBIT" }
            .reduce(0) { sum, transaction in
                sum + Double(abs(transaction.amount))
            }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Balance Card
                balanceCard
                
                // Quick Actions
                quickActionsSection
                
                // Recent Activity
                recentActivitySection
            }
            .padding(20)
        }
        .background(
            ZStack {
                Color(hex: "0a0a0a").ignoresSafeArea()
                
                // Decorative gradients
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "6366f1").opacity(0.3), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 400, height: 400)
                    .offset(x: -100, y: -150)
                    .blur(radius: 60)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "ec4899").opacity(0.2), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: 300, height: 300)
                    .offset(x: 150, y: 400)
                    .blur(radius: 60)
            }
        )
        .navigationBarHidden(true)
        .sheet(isPresented: $showProfile) {
            ProfileView()
                .environmentObject(viewModel)
        }
        .onAppear {
            if let userID = viewModel.currentUser?.userID {
                transactionViewModel.fetchTransactions(userID: userID)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back,")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                
                Text(viewModel.currentUser?.name ?? "User")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Profile Button
            Button {
                showProfile = true
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "6366f1"), Color(hex: "ec4899")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Text(initials)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.top, 10)
    }
    
    private var initials: String {
        let first = viewModel.currentUser?.name.prefix(1) ?? "U"
        let last = viewModel.currentUser?.lastName.prefix(1) ?? ""
        return "\(first)\(last)"
    }
    
    // MARK: - Balance Card
    private var balanceCard: some View {
        VStack(spacing: 20) {
            if transactionViewModel.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text("Loading...")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 8) {
                    Text("Total Balance")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(formatCurrency(totalBalance))
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    if transactionViewModel.transactions.isEmpty {
                        Text("No transactions yet")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                
                if !transactionViewModel.transactions.isEmpty {
                    HStack(spacing: 16) {
                        balanceStatItem(title: "Income", amount: "+\(formatCurrency(totalIncome))", color: Color(hex: "34d399"))
                        
                        Divider()
                            .frame(height: 40)
                            .background(.white.opacity(0.2))
                        
                        balanceStatItem(title: "Expenses", amount: "-\(formatCurrency(totalExpenses))", color: Color(hex: "f87171"))
                    }
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "1f1f1f"), Color(hex: "171717")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.1), .white.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color(hex: "6366f1").opacity(0.2), radius: 30, y: 10)
        )
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: abs(amount))) ?? "$0.00"
    }
    
    private func balanceStatItem(title: String, amount: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
            Text(amount)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                NavigationLink(destination: TransferView().environmentObject(viewModel)) {
                    quickActionCard(
                        icon: "paperplane.fill",
                        title: "Transfer",
                        gradient: [Color(hex: "ff6b6b"), Color(hex: "ff8e53")]
                    )
                }
                
                NavigationLink(destination: CreateAccountView().environmentObject(viewModel)) {
                    quickActionCard(
                        icon: "plus.circle.fill",
                        title: "New Account",
                        gradient: [Color(hex: "00d9ff"), Color(hex: "00ff88")]
                    )
                }
                
                NavigationLink(destination: TransactionHistoryView().environmentObject(viewModel)) {
                    quickActionCard(
                        icon: "clock.fill",
                        title: "History",
                        gradient: [Color(hex: "a78bfa"), Color(hex: "ec4899")]
                    )
                }
            }
        }
    }
    
    private func quickActionCard(icon: String, title: String, gradient: [Color]) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .shadow(color: gradient[0].opacity(0.5), radius: 10, y: 5)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }
            
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Recent Activity
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                if !transactionViewModel.transactions.isEmpty {
                    NavigationLink(destination: TransactionHistoryView().environmentObject(viewModel)) {
                        Text("See All")
                            .font(.subheadline.bold())
                            .foregroundColor(Color(hex: "6366f1"))
                    }
                }
            }
            
            if transactionViewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Spacer()
                }
                .padding(.vertical, 40)
            } else if transactionViewModel.transactions.isEmpty {
                emptyActivityCard
            } else {
                VStack(spacing: 12) {
                    ForEach(transactionViewModel.transactions.prefix(5)) { transaction in
                        activityRow(transaction)
                    }
                }
            }
        }
    }
    
    private var emptyActivityCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.3))
            
            Text("No transactions yet")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.5))
            
            Text("Create an account and make your first transfer")
                .font(.caption)
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.03))
        )
    }
    
    private func activityRow(_ transaction: TransactionItem) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(typeColor(transaction.type).opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: typeIcon(transaction.type))
                    .font(.system(size: 18))
                    .foregroundColor(typeColor(transaction.type))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.description.isEmpty ? "Transaction" : transaction.description)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(transaction.date.isEmpty ? "-" : transaction.date)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
            }
            
            Spacer()
            
            Text(formatAmount(transaction.amount, type: transaction.type))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(transaction.type.uppercased() == "CREDIT" ? Color(hex: "34d399") : Color(hex: "f87171"))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white.opacity(0.03))
        )
    }
    
    private func typeIcon(_ type: String) -> String {
        switch type.uppercased() {
        case "CREDIT": return "arrow.down.left"
        case "DEBIT": return "arrow.up.right"
        case "TRANSFER": return "arrow.left.arrow.right"
        default: return "dollarsign.circle"
        }
    }
    
    private func typeColor(_ type: String) -> Color {
        switch type.uppercased() {
        case "CREDIT": return Color(hex: "34d399")
        case "DEBIT": return Color(hex: "f87171")
        case "TRANSFER": return Color(hex: "60a5fa")
        default: return Color(hex: "a78bfa")
        }
    }
    
    private func formatAmount(_ amount: Int, type: String) -> String {
        let prefix = type.uppercased() == "CREDIT" ? "+" : "-"
        return "\(prefix)$\(abs(amount))"
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: LoginViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "6366f1"), Color(hex: "ec4899")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Text(initials)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)
                    
                    // Name
                    VStack(spacing: 4) {
                        Text("\(viewModel.currentUser?.name ?? "") \(viewModel.currentUser?.lastName ?? "")")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        Text(viewModel.currentUser?.accountType ?? "Account")
                    .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("User ID: \(viewModel.currentUser?.userID ?? 0)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.4))
                    }
                    
                    // Info Cards
                    VStack(spacing: 16) {
                        profileInfoRow(icon: "at", title: "Username", value: viewModel.currentUser?.username ?? "N/A")
                        profileInfoRow(icon: "phone.fill", title: "Phone", value: viewModel.currentUser?.phoneNumber ?? "N/A")
                        profileInfoRow(icon: "house.fill", title: "Address", value: viewModel.currentUser?.address ?? "N/A")
                        profileInfoRow(icon: "building.columns.fill", title: "Account Type", value: viewModel.currentUser?.accountType ?? "N/A")
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.white.opacity(0.05))
                    )
                    
                    // Logout Button
                    Button {
                        viewModel.logout()
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "f87171").opacity(0.2))
                        .foregroundColor(Color(hex: "f87171"))
                        .cornerRadius(14)
                    }
                }
                .padding(24)
            }
            .background(Color(hex: "0a0a0a").ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color(hex: "0a0a0a"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
        }
    }
    
    private var initials: String {
        let first = viewModel.currentUser?.name.prefix(1) ?? "U"
        let last = viewModel.currentUser?.lastName.prefix(1) ?? ""
        return "\(first)\(last)"
    }
    
    private func profileInfoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: "6366f1").opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "6366f1"))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(LoginViewModel())
    }
}
