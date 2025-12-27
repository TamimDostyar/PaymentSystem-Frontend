//
//  TransferView.swift
//  PaymentSystem
//
//  Created by Ahmad Tamim Dostyar on 12/26/25.
//

import SwiftUI

struct TransferView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var loginViewModel: LoginViewModel
    @StateObject private var viewModel = TransactionViewModel()
    
    // From Account
    @State private var fromAccountNumber = ""
    @State private var fromRoutingNumber = ""
    
    // To Account
    @State private var toAccountNumber = ""
    @State private var toRoutingNumber = ""
    
    // Transfer Details
    @State private var amount = ""
    @State private var description = ""
    
    @State private var showConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Amount Section
                amountSection
                
                // From Account Section
                fromAccountSection
                
                // Transfer Arrow
                transferArrow
                
                // To Account Section
                toAccountSection
                
                // Description
                descriptionSection
                
                // Transfer Button
                transferButton
                
                // Messages
                messagesSection
                
                // Success Card
                if let result = viewModel.transferResult, result.success != nil {
                    successCard(result)
                }
            }
            .padding(24)
        }
        .background(
            ZStack {
                Color(hex: "0a0a0a").ignoresSafeArea()
                
                Circle()
                    .fill(Color(hex: "ff6b6b").opacity(0.1))
                    .frame(width: 300, height: 300)
                    .blur(radius: 100)
                    .offset(x: -150, y: -200)
                
                Circle()
                    .fill(Color(hex: "4ecdc4").opacity(0.1))
                    .frame(width: 300, height: 300)
                    .blur(radius: 100)
                    .offset(x: 150, y: 300)
            }
        )
        .navigationTitle("Transfer Money")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color(hex: "0a0a0a"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .alert("Confirm Transfer", isPresented: $showConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Transfer", role: .destructive) {
                executeTransfer()
            }
        } message: {
            Text("Transfer $\(amount) to account \(toAccountNumber)?")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "ff6b6b"), Color(hex: "ff8e53")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                    .shadow(color: Color(hex: "ff6b6b").opacity(0.5), radius: 15)
                
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("Send Money")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.top, 10)
    }
    
    // MARK: - Amount Section
    private var amountSection: some View {
        VStack(spacing: 8) {
            Text("Amount")
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
            
            HStack(alignment: .center, spacing: 4) {
                Text("$")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color(hex: "ff6b6b"))
                
                TextField("0", text: $amount)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .frame(minWidth: 100)
            }
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - From Account Section
    private var fromAccountSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("From Account", systemImage: "arrow.up.circle.fill")
                .font(.subheadline.bold())
                .foregroundColor(Color(hex: "ff6b6b"))
            
            VStack(spacing: 12) {
                accountField(
                    icon: "number.circle",
                    placeholder: "Account Number",
                    text: $fromAccountNumber,
                    keyboardType: .numberPad
                )
                
                accountField(
                    icon: "arrow.triangle.branch",
                    placeholder: "Routing Number",
                    text: $fromRoutingNumber,
                    keyboardType: .numberPad
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "ff6b6b").opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Transfer Arrow
    private var transferArrow: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "1a1a1a"))
                .frame(width: 50, height: 50)
            
            Image(systemName: "arrow.down.circle.fill")
                .font(.system(size: 30))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "ff6b6b"), Color(hex: "4ecdc4")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
    }
    
    // MARK: - To Account Section
    private var toAccountSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("To Account", systemImage: "arrow.down.circle.fill")
                .font(.subheadline.bold())
                .foregroundColor(Color(hex: "4ecdc4"))
            
            VStack(spacing: 12) {
                accountField(
                    icon: "number.circle",
                    placeholder: "Account Number",
                    text: $toAccountNumber,
                    keyboardType: .numberPad
                )
                
                accountField(
                    icon: "arrow.triangle.branch",
                    placeholder: "Routing Number",
                    text: $toRoutingNumber,
                    keyboardType: .numberPad
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "4ecdc4").opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Account Field
    private func accountField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 24)
            
            TextField("", text: text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.3)))
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.white)
                .keyboardType(keyboardType)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.05))
        )
    }
    
    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Note (Optional)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
            
            TextField("", text: $description, prompt: Text("What's this for?").foregroundColor(.white.opacity(0.3)))
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white.opacity(0.05))
                )
        }
    }
    
    // MARK: - Transfer Button
    private var transferButton: some View {
        Button {
            showConfirmation = true
        } label: {
            HStack(spacing: 12) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "paperplane.fill")
                    Text("Transfer")
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: canTransfer ? [Color(hex: "ff6b6b"), Color(hex: "ff8e53")] : [.gray, .gray],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(16)
            .shadow(color: canTransfer ? Color(hex: "ff6b6b").opacity(0.4) : .clear, radius: 10, y: 5)
        }
        .disabled(!canTransfer || viewModel.isLoading)
    }
    
    private var canTransfer: Bool {
        !fromAccountNumber.isEmpty &&
        !fromRoutingNumber.isEmpty &&
        !toAccountNumber.isEmpty &&
        !toRoutingNumber.isEmpty &&
        !amount.isEmpty &&
        Int(amount) ?? 0 > 0
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
        }
    }
    
    // MARK: - Success Card
    private func successCard(_ result: TransferResponse) -> some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(.green.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
            }
            
            Text("Transfer Successful!")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            if let amount = result.amount {
                Text("$\(amount)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "4ecdc4"))
            }
            
            VStack(spacing: 8) {
                if let from = result.from {
                    Text("From: \(from)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                if let to = result.to {
                    Text("To: \(to)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Button {
                dismiss()
            } label: {
                Text("Done")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: "4ecdc4"))
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
    
    // MARK: - Execute Transfer
    private func executeTransfer() {
        guard let amountInt = Int(amount),
              let fromRouting = Int(fromRoutingNumber),
              let toRouting = Int(toRoutingNumber) else { return }
        
        viewModel.makeTransfer(
            fromAccountNumber: fromAccountNumber,
            fromRoutingNumber: fromRouting,
            toAccountNumber: toAccountNumber,
            toRoutingNumber: toRouting,
            amount: amountInt,
            description: description.isEmpty ? nil : description
        )
    }
}

#Preview {
    NavigationStack {
        TransferView()
    }
}

