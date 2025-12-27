//
//  APIService.swift
//  PaymentSystem
//
//  Created by Ahmad Tamim Dostyar on 12/26/25.
//

import Foundation

final class APIService {
    private let baseURL = APIKeyManager.baseURL
    
    private var commonHeaders: [String: String] {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    // MARK: - Generic Request
    func makeRequest<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        queryParams: [String: String]? = nil,
        body: (any Encodable)? = nil
    ) async throws -> T {
        
        var urlComponents = URLComponents(string: "\(baseURL)/\(endpoint)")
        
        if let queryParams = queryParams {
            urlComponents?.queryItems = queryParams.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }
        
        guard let url = urlComponents?.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        commonHeaders.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
            throw APIError.decodingFailed
        }
    }
    
    // For endpoints that accept plain string body
    func makeRequestWithStringBody<T: Decodable>(
        endpoint: String,
        method: String = "POST",
        body: String
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = body.data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
            throw APIError.decodingFailed
        }
    }
    
    // MARK: - User Endpoints
    
    /// Login - Get user data by username
    func login(user: LoginRequest) async throws -> LoginResponse {
        return try await makeRequestWithStringBody(endpoint: "get-data-byUsername", method: "POST", body: user.username)
    }
    
    /// Create a new user
    func createUser(user: CreateUserRequest) async throws -> CreateUserResponse {
        return try await makeRequest(endpoint: "createUser", method: "POST", body: user)
    }
    
    /// Check if username exists
    func checkUsernameExists(username: String) async throws -> UsernameExistsResponse {
        return try await makeRequestWithStringBody(endpoint: "user-data-exist", method: "POST", body: username)
    }
    
    /// Delete user by username
    func deleteUser(username: String) async throws -> APIResponse {
        return try await makeRequestWithStringBody(endpoint: "delete-data-byUsername", method: "POST", body: username)
    }
    
    // MARK: - Account Endpoints
    
    /// Initialize database (admin function)
    func initializeDatabase() async throws -> APIResponse {
        return try await makeRequest(endpoint: "db-init", method: "GET")
    }
    
    /// Create a bank account for a user
    func createAccount(userID: Int, account: CreateAccountRequest) async throws -> CreateAccountResponse {
        return try await makeRequest(endpoint: "createAccount/\(userID)", method: "POST", body: account)
    }
    
    /// Get bank account for a user
    func getAccount(userID: Int) async throws -> GetAccountResponse {
        return try await makeRequest(endpoint: "getAccount/\(userID)", method: "GET")
    }
    
    // MARK: - Transaction Endpoints
    
    /// Initialize transaction table (admin function)
    func initializeTransactionTable() async throws -> APIResponse {
        return try await makeRequest(endpoint: "transaction/init", method: "GET")
    }
    
    /// Create a transaction record
    func createTransaction(accountID: Int, transaction: CreateTransactionRequest) async throws -> CreateTransactionResponse {
        return try await makeRequest(endpoint: "transaction/create/\(accountID)", method: "POST", body: transaction)
    }
    
    /// Transfer money between accounts
    func makeTransfer(transfer: TransferRequest) async throws -> TransferResponse {
        return try await makeRequest(endpoint: "transaction/transfer", method: "POST", body: transfer)
    }
    
    /// Get transaction history for a user
    func getTransactionHistory(userID: Int) async throws -> TransactionHistoryResponse {
        let request = TransactionHistoryRequest(userID: userID)
        return try await makeRequest(endpoint: "user-transaction", method: "POST", body: request)
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed
    case decodingFailed
    case unauthorized
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed:
            return "Request failed. Please try again."
        case .decodingFailed:
            return "Failed to process server response"
        case .unauthorized:
            return "Unauthorized access"
        case .serverError(let message):
            return message
        }
    }
}
