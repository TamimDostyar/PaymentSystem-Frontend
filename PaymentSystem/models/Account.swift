//
//  Account.swift
//  PaymentSystem
//
//  Created by Ahmad Tamim Dostyar on 12/26/25.
//

import Foundation

struct Account: Identifiable, Codable {
    var id: UUID = UUID()
    var accountNumber: String
    var routingNumber: Int
    var amountAvail: Double
    
    enum CodingKeys: String, CodingKey {
        case accountNumber, routingNumber, amountAvail
    }
}

// MARK: - Create Account
struct CreateAccountRequest: Codable {
    var routingNumber: Int?
    var accountNumber: String?
    var amountAvail: Double
}

struct CreateAccountResponse: Codable {
    var success: String?
    var error: String?
    var accountNumber: String?
    var routingNumber: String?
}

// MARK: - Generic API Response
struct APIResponse: Codable {
    var Success: String?
    var Error: String?
    var success: String?
    var error: String?
    
    var isSuccess: Bool {
        return Success != nil || success != nil
    }
    
    var message: String? {
        return Success ?? success ?? Error ?? error
    }
    
    var errorMessage: String? {
        return Error ?? error
    }
}

