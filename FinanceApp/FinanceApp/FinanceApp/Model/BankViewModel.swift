//
//  BankViewModel.swift
//  FinanceApp
//
//  Created by Tina  on 9.02.25.
//

import FirebaseFirestore
import SwiftUI

class BankViewModel: ObservableObject {
    @Published var banks: [Bank] = []
    @Published var isLoading: Bool = false  // Track loading state
    @Published var errorMessage: String?   // Store error message if fetch fails

    private var db = Firestore.firestore()

    func fetchBanks() {
        isLoading = true  // Start loading

        db.collection("banks").getDocuments { snapshot, error in
            self.isLoading = false  // Stop loading

            if let error = error {
                self.errorMessage = "Error fetching banks: \(error.localizedDescription)"
                return
            }

            if let snapshot = snapshot {
                self.banks = snapshot.documents.compactMap { document in
                    try? document.data(as: Bank.self)
                }
            }
        }
    }
}

