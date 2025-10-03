//
//  BankAPI.swift
//  FinanceApp
//
//  Created by Tina  on 13.02.25.
//

import SwiftUI

// Model for Transactions
struct Transaction: Codable, Identifiable, Equatable {
    var id: UUID { UUID() }  // Generate a unique ID
    let date: String
    let amount: Double
    let description: String

    // Custom Equatable check to prevent duplicates (based on date & description)
    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs.date == rhs.date && lhs.description == rhs.description && lhs.amount == rhs.amount
    }
}

// ViewModel to manage WebSocket connection
class BankAPI: ObservableObject {
    @Published var transactions: [Transaction] = []
    private var webSocketTask: URLSessionWebSocketTask?

    func fetchTransactions() {
        guard let url = URL(string: "ws://127.0.0.1:8000/ws") else { return }
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()

        receiveData()
    }

    private func receiveData() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received data: \(text)")  // ✅ Debugging step
                    if let data = text.data(using: .utf8) {
                        do {
                            let newTransactions = try JSONDecoder().decode([Transaction].self, from: data)
                            DispatchQueue.main.async {
                                self?.transactions = newTransactions
                            }
                        } catch {
                            print("JSON Decoding Error: \(error)")  // ✅ Print errors
                        }
                    }
                default:
                    break
                }
                
                // ✅ Close connection after receiving data once
                self?.disconnect()

            case .failure(let error):
                print("WebSocket Error: \(error)")
                self?.disconnect()
            }
        }
    }

    func disconnect() {
        webSocketTask?.cancel()
        webSocketTask = nil
    }
}

