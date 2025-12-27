//
//  Transaction.swift
//  PaymentSystem
//
//  Created by Ahmad Tamim Dostyar on 12/26/25.
//

import Foundation

struct Transaction: Identifiable, Codable {
    var id: UUID = UUID()
    var description: String
    var transAmount: Int
    var date: String
    var type: String // DEBIT, CREDIT, TRANSFER
    var status: String // COMPLETE, FAIL, PENDING
    
    enum CodingKeys: String, CodingKey {
        case description, transAmount, date, type, status
    }
}

// MARK: - Create Transaction
struct CreateTransactionRequest: Codable {
    var description: String
    var transAmount: Int
    var type: String
    var status: String?
}

struct CreateTransactionResponse: Codable {
    var success: String?
    var error: String?
}

// MARK: - Transfer
struct TransferRequest: Codable {
    var fromAccountNumber: String
    var fromRoutingNumber: Int
    var toAccountNumber: String
    var toRoutingNumber: Int
    var amount: Int
    var description: String?
}

struct TransferResponse: Codable {
    var success: String?
    var error: String?
    var amount: String?
    var from: String?
    var to: String?
}

// MARK: - Transaction History
struct TransactionHistoryRequest: Codable {
    var userID: Int
}

struct TransactionHistoryResponse: Codable {
    var Success: String?
    var Error: String?
    var info: String?
    
    var isSuccess: Bool {
        return Success == "True"
    }
    
    var transactions: [TransactionItem] {
        guard let info = info, !info.isEmpty, info != "No transaction data found for the given user ID." else {
            return []
        }
        return parseTransactions(from: info)
    }
    
    private func parseTransactions(from info: String) -> [TransactionItem] {
        // Parse the transaction string from backend
        // Expected format may vary, adjust parsing as needed
        var items: [TransactionItem] = []
        let lines = info.components(separatedBy: "\n")
        for line in lines where !line.isEmpty {
            items.append(TransactionItem(rawData: line))
        }
        return items
    }
}

struct TransactionItem: Identifiable {
    var id = UUID()
    var rawData: String
    var description: String = ""
    var amount: Int = 0
    var date: String = ""
    var type: String = ""
    var status: String = ""
    var accountNumber: String = ""
    
    init(rawData: String) {
        self.rawData = rawData
        parseRawData()
    }
    
    private mutating func parseRawData() {
        // Parse format from backend:
        // "Transaction: Amount: $100, Date: 2025-01-01, Type: DEBIT, Status: COMPLETE, Description: Transfer, Account: 123456789012"
        var workingString = rawData
        
        // Remove "Transaction: " prefix if present
        if workingString.hasPrefix("Transaction: ") {
            workingString = String(workingString.dropFirst("Transaction: ".count))
        }
        
        // Split by ", " to get key-value pairs
        let components = workingString.components(separatedBy: ", ")
        for component in components {
            // Find the first ": " to split key and value
            if let colonRange = component.range(of: ": ") {
                let key = String(component[..<colonRange.lowerBound]).trimmingCharacters(in: .whitespaces).lowercased()
                var value = String(component[colonRange.upperBound...]).trimmingCharacters(in: .whitespaces)
                
                switch key {
                case "amount":
                    // Remove $ sign and parse
                    value = value.replacingOccurrences(of: "$", with: "")
                    amount = Int(value) ?? 0
                case "date":
                    date = value
                case "type":
                    type = value
                case "status":
                    status = value
                case "description":
                    description = value
                case "account":
                    accountNumber = value
                default:
                    break
                }
            }
        }
        
        // If parsing failed, use rawData as description
        if description.isEmpty && amount == 0 {
            description = rawData
        }
    }
}

// Transaction Types
enum TransactionType: String, CaseIterable {
    case debit = "DEBIT"
    case credit = "CREDIT"
    case transfer = "TRANSFER"
    
    var displayName: String {
        switch self {
        case .debit: return "Debit"
        case .credit: return "Credit"
        case .transfer: return "Transfer"
        }
    }
    
    var icon: String {
        switch self {
        case .debit: return "arrow.up.circle.fill"
        case .credit: return "arrow.down.circle.fill"
        case .transfer: return "arrow.left.arrow.right.circle.fill"
        }
    }
}

enum TransactionStatus: String, CaseIterable {
    case complete = "COMPLETE"
    case pending = "PENDING"
    case fail = "FAIL"
    
    var displayName: String {
        switch self {
        case .complete: return "Complete"
        case .pending: return "Pending"
        case .fail: return "Failed"
        }
    }
}

