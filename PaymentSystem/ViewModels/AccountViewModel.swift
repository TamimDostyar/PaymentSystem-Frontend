//
//  AccountViewModel.swift
//  PaymentSystem
//
//  Created by Ahmad Tamim Dostyar on 12/26/25.
//

import SwiftUI
import Combine

class AccountViewModel: ObservableObject {
    @Published var account: Account?
    @Published var accountResponse: GetAccountResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var hasAccount = false
    
    private let apiService: APIService
    
    init(apiService: APIService = APIService()) {
        self.apiService = apiService
    }
    
    func fetchAccount(userID: Int) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await apiService.getAccount(userID: userID)
                
                await MainActor.run {
                    self.isLoading = false
                    self.accountResponse = response
                    
                    if response.hasAccount {
                        self.hasAccount = true
                        if let accountNum = response.accountNumber,
                           let routingNum = response.routingNumber,
                           let routing = Int(routingNum) {
                            self.account = Account(
                                accountNumber: accountNum,
                                routingNumber: routing,
                                amountAvail: response.balanceDouble
                            )
                        }
                    } else {
                        self.hasAccount = false
                        self.account = nil
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.hasAccount = false
                    // Don't show error for no account - it's expected for new users
                }
            }
        }
    }
    
    func createAccount(userID: Int, initialAmount: Double) {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        let request = CreateAccountRequest(amountAvail: initialAmount)
        
        Task {
            do {
                let response = try await apiService.createAccount(userID: userID, account: request)
                
                await MainActor.run {
                    self.isLoading = false
                    
                    if let error = response.error {
                        self.errorMessage = error
                    } else if let accountNum = response.accountNumber,
                              let routingNum = response.routingNumber,
                              let routing = Int(routingNum) {
                        self.account = Account(
                            accountNumber: accountNum,
                            routingNumber: routing,
                            amountAvail: initialAmount
                        )
                        self.hasAccount = true
                        self.successMessage = "Account created successfully!"
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
    }
}

