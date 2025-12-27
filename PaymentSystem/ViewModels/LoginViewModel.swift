//
//  LoginViewModel.swift
//  PaymentSystem
//
//  Created by Ahmad Tamim Dostyar on 12/26/25.
//

import SwiftUI
import Combine

class LoginViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var loginResponse: LoginResponse?
    
    private let apiService: APIService
    
    init(apiService: APIService = APIService()) {
        self.apiService = apiService
    }
    
    func login(username: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await apiService.login(user: LoginRequest(username: username))

                await MainActor.run {
                    self.loginResponse = response
                    self.currentUser = User(
                        userID: response.userID,
                        name: response.name,
                        lastName: response.lastName,
                        address: response.address,
                        accountType: response.accountType,
                        phoneNumber: response.phoneNumber,
                        username: username
                    )
                    self.isLoggedIn = true
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Login failed. Please check your credentials."
                    self.isLoading = false
                }
            }
        }
    }
    
    func logout() {
        currentUser = nil
        loginResponse = nil
        isLoggedIn = false
        errorMessage = nil
    }
    
    func updateUserAccount(accountNumber: String, routingNumber: Int, balance: Double) {
        currentUser?.accountNumber = accountNumber
        currentUser?.routingNumber = routingNumber
        currentUser?.balance = balance
    }
}
