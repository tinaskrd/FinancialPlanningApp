//
//  TipModel.swift
//  FinanceApp
//
//  Created by Tina  on 13.02.25.
//

import Foundation
import FirebaseFirestore

struct FinancialTip: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var content: String
    var date: Date
}

