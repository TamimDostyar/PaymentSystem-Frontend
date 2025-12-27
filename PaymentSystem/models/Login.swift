//
//  Login.swift
//  PaymentSystem
//
//  Created by Ahmad Tamim Dostyar on 12/26/25.
//

import Foundation

struct LoginRequest: Codable {
    let username: String
}

struct LoginResponse: Codable {
    let id: String
    let name: String
    let lastName: String
    let address: String
    let accountType: String
    let phoneNumber: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, lastName, address, accountType
        case phoneNumber = "Phone Number"
    }
    
    var userID: Int {
        return Int(id) ?? 0
    }
}
