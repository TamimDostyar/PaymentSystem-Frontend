//
//  SignUpViewModel.swift
//  PaymentSystem
//
//  Created by Ahmad Tamim Dostyar on 12/26/25.
//

import SwiftUI
import Combine

class SignUpViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSignUpSuccessful = false
    @Published var usernameAvailable: Bool?
    @Published var checkingUsername = false
    
    private let apiService: APIService
    
    init(apiService: APIService = APIService()) {
        self.apiService = apiService
    }
    
    func signUp(
        name: String,
        lastName: String,
        address: String,
        accountType: AccountType,
        phoneNumber: String,
        username: String,
        password: String,
        confirmPassword: String
    ) {
        // Validation
        guard !name.isEmpty else {
            errorMessage = "Please enter your first name"
            return
        }
        guard !lastName.isEmpty else {
            errorMessage = "Please enter your last name"
            return
        }
        guard !address.isEmpty else {
            errorMessage = "Please enter your address"
            return
        }
        guard !phoneNumber.isEmpty else {
            errorMessage = "Please enter your phone number"
            return
        }
        guard !username.isEmpty else {
            errorMessage = "Please enter a username"
            return
        }
        guard username.count >= 3 else {
            errorMessage = "Username must be at least 3 characters"
            return
        }
        guard !password.isEmpty else {
            errorMessage = "Please enter a password"
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let request = CreateUserRequest(
            name: name,
            lastName: lastName,
            address: address,
            accountType: accountType.rawValue,
            phoneNumber: phoneNumber,
            username: username,
            password: password,
            confirmPassword: confirmPassword
        )
        
        Task {
            do {
                let response = try await apiService.createUser(user: request)
                
                await MainActor.run {
                    self.isLoading = false
                    
                    if response.isSuccess {
                        self.isSignUpSuccessful = true
                    } else {
                        self.errorMessage = response.Error ?? "Failed to create account"
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
    
    func checkUsernameAvailability(username: String) {
        guard !username.isEmpty, username.count >= 3 else {
            usernameAvailable = nil
            return
        }
        
        checkingUsername = true
        
        Task {
            do {
                let response = try await apiService.checkUsernameExists(username: username)
                
                await MainActor.run {
                    self.checkingUsername = false
                    self.usernameAvailable = !response.exists
                }
            } catch {
                await MainActor.run {
                    self.checkingUsername = false
                    self.usernameAvailable = nil
                }
            }
        }
    }
    
    func clearMessages() {
        errorMessage = nil
    }
}

