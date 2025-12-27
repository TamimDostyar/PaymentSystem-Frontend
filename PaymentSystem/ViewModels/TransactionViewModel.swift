//
//  TransactionViewModel.swift
//  PaymentSystem
//
//  Created by Ahmad Tamim Dostyar on 12/26/25.
//

import SwiftUI
import Combine

class TransactionViewModel: ObservableObject {
    @Published var transactions: [TransactionItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var transferResult: TransferResponse?
    
    private let apiService: APIService
    
    init(apiService: APIService = APIService()) {
        self.apiService = apiService
    }
    
    // MARK: - Get Transaction History
    func fetchTransactions(userID: Int) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await apiService.getTransactionHistory(userID: userID)
                
                await MainActor.run {
                    self.isLoading = false
                    
                    if let error = response.Error {
                        self.errorMessage = error
                    } else {
                        self.transactions = response.transactions
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Make Transfer
    func makeTransfer(
        fromAccountNumber: String,
        fromRoutingNumber: Int,
        toAccountNumber: String,
        toRoutingNumber: Int,
        amount: Int,
        description: String?
    ) {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        let request = TransferRequest(
            fromAccountNumber: fromAccountNumber,
            fromRoutingNumber: fromRoutingNumber,
            toAccountNumber: toAccountNumber,
            toRoutingNumber: toRoutingNumber,
            amount: amount,
            description: description
        )
        
        Task {
            do {
                let response = try await apiService.makeTransfer(transfer: request)
                
                await MainActor.run {
                    self.isLoading = false
                    self.transferResult = response
                    
                    if let error = response.error {
                        self.errorMessage = error
                    } else if let success = response.success {
                        self.successMessage = success
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Create Transaction
    func createTransaction(
        accountID: Int,
        description: String,
        amount: Int,
        type: TransactionType,
        status: TransactionStatus = .pending
    ) {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        let request = CreateTransactionRequest(
            description: description,
            transAmount: amount,
            type: type.rawValue,
            status: status.rawValue
        )
        
        Task {
            do {
                let response = try await apiService.createTransaction(accountID: accountID, transaction: request)
                
                await MainActor.run {
                    self.isLoading = false
                    
                    if let error = response.error {
                        self.errorMessage = error
                    } else if let success = response.success {
                        self.successMessage = success
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
        transferResult = nil
    }
}

