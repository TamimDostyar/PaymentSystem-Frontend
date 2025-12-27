//
//  CreateUser.swift
//  PaymentSystem
//
//  Created by Ahmad Tamim Dostyar on 12/26/25.
//

import Foundation

struct CreateUserRequest: Codable {
    var name: String
    var lastName: String
    var address: String
    var accountType: String
    var phoneNumber: String
    var username: String
    var password: String
    var confirmPassword: String
}

struct CreateUserResponse: Codable {
    var Success: String?
    var Error: String?
    
    var isSuccess: Bool {
        return Success != nil
    }
    
    var message: String? {
        return Success ?? Error
    }
}

struct UsernameExistsRequest: Codable {
    var username: String
}

struct UsernameExistsResponse: Codable {
    var Exists: String?
    var Message: String?
    var Error: String?
    
    var exists: Bool {
        return Exists == "true"
    }
}

// Account types available
enum AccountType: String, CaseIterable {
    case checking = "Checking"
    case savings = "Savings"
    case business = "Business"
    
    var displayName: String {
        return rawValue
    }
}

