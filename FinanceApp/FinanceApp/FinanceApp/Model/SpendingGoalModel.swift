//
//  SpendingGoalModel.swift
//  FinanceApp
//
//  Created by Tina  on 17.02.25.
//

import SwiftUI
import FirebaseFirestore

//
//struct SpendingGoal: Identifiable, Codable {
//    let id: UUID
//    var category: String
//    var goalAmount: Double
//    var spentAmount: Double
//    
//    init(id: UUID = UUID(), category: String, goalAmount: Double, spentAmount: Double) {
//        self.id = id
//        self.category = category
//        self.goalAmount = goalAmount
//        self.spentAmount = spentAmount
//    }
//}


struct SpendingGoal: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    var userId: String  // User-specific goals
    var category: String
    var goalAmount: Double
}

