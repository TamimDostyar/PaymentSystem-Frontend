//
//  CreateAccountView.swift
//  PaymentSystem
//
//  Created by Ahmad Tamim Dostyar on 12/26/25.
//

import SwiftUI

struct CreateAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AccountViewModel()
    @EnvironmentObject var loginViewModel: LoginViewModel
    
    @State private var initialAmount = ""
    @State private var showSuccessAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header Card
                headerCard
                
                // Amount Input
                amountInput
                
                // Info Card
                infoCard
                
                // Create Button
                createButton
                
                // Error/Success Messages
                messagesSection
                
                // Created Account Details
                if let account = viewModel.account {
                    accountDetailsCard(account)
                }
            }
            .padding(24)
        }
        .background(
            LinearGradient(
                colors: [Color(hex: "1a1a2e"), Color(hex: "16213e"), Color(hex: "0f3460")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color(hex: "1a1a2e"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "00d9ff"), Color(hex: "00ff88")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: Color(hex: "00d9ff").opacity(0.5), radius: 20)
                
                Image(systemName: "building.columns.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            Text("Open New Account")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Create a bank account with an initial deposit")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Amount Input
    private var amountInput: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Initial Deposit")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
            
            HStack(spacing: 16) {
                Text("$")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(hex: "00d9ff"))
                
                TextField("0.00", text: $initialAmount)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.leading)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [Color(hex: "00d9ff").opacity(0.5), Color(hex: "00ff88").opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
        }
    }
    
    // MARK: - Info Card
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(Color(hex: "00d9ff"))
                Text("Account Information")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                infoRow(icon: "number.circle.fill", title: "Account Number", value: "Auto-generated (12 digits)")
                infoRow(icon: "arrow.triangle.branch", title: "Routing Number", value: "Auto-generated (9 digits)")
                infoRow(icon: "person.fill", title: "Account Holder", value: "\(loginViewModel.currentUser?.name ?? "") \(loginViewModel.currentUser?.lastName ?? "")")
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.05))
        )
    }
    
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "00ff88"))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
        }
    }
    
    // MARK: - Create Button
    private var createButton: some View {
        Button {
            if let amount = Double(initialAmount),
               let userID = loginViewModel.currentUser?.userID {
                viewModel.createAccount(userID: userID, initialAmount: amount)
            }
        } label: {
            HStack(spacing: 12) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Account")
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [Color(hex: "00d9ff"), Color(hex: "00ff88")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.black)
            .cornerRadius(16)
            .shadow(color: Color(hex: "00d9ff").opacity(0.4), radius: 10, y: 5)
        }
        .disabled(viewModel.isLoading || initialAmount.isEmpty)
        .opacity(initialAmount.isEmpty ? 0.6 : 1)
    }
    
    // MARK: - Messages Section
    private var messagesSection: some View {
        VStack(spacing: 12) {
            if let error = viewModel.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text(error)
                        .font(.subheadline)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.red.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.red.opacity(0.5), lineWidth: 1)
                        )
                )
            }
            
            if let success = viewModel.successMessage {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text(success)
                        .font(.subheadline)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.green.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.green.opacity(0.5), lineWidth: 1)
                        )
                )
            }
        }
    }
    
    // MARK: - Account Details Card
    private func accountDetailsCard(_ account: Account) -> some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                Text("Account Created!")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 16) {
                accountDetailRow(label: "Account Number", value: account.accountNumber)
                accountDetailRow(label: "Routing Number", value: String(account.routingNumber))
                accountDetailRow(label: "Balance", value: String(format: "$%.2f", account.amountAvail))
            }
            
            Button {
                dismiss()
            } label: {
                Text("Done")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: "00ff88"))
                    .foregroundColor(.black)
                    .cornerRadius(12)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.green.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    private func accountDetailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
            Spacer()
            Text(value)
                .font(.system(.subheadline, design: .monospaced))
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        CreateAccountView()
            .environmentObject(LoginViewModel())
    }
}

