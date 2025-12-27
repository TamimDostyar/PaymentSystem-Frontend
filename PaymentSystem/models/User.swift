//
//  User.swift
//  PaymentSystem
//
//  Created by Ahmad Tamim Dostyar on 12/26/25.
//

import Foundation

struct User: Identifiable, Codable {
    var id: UUID
    var userID: Int // Backend user ID for API calls
    var name: String
    var lastName: String
    var address: String
    var accountType: String
    var phoneNumber: String
    var username: String
    
    // Account info (optional, populated after creating bank account)
    var accountNumber: String?
    var routingNumber: Int?
    var balance: Double?
    
    init(id: UUID = UUID(), userID: Int = 1, name: String, lastName: String, address: String, accountType: String, phoneNumber: String, username: String = "") {
        self.id = id
        self.userID = userID
        self.name = name
        self.lastName = lastName
        self.address = address
        self.accountType = accountType
        self.phoneNumber = phoneNumber
        self.username = username
    }
    
    static let sample = User(userID: 1, name: "Tamim", lastName: "Dostyar", address: "123 Main St", accountType: "Checking", phoneNumber: "123-456-7890", username: "tamim")
}
