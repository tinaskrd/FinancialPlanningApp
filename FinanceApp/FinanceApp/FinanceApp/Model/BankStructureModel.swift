//
//  BankStructureModel.swift
//  FinanceApp
//
//  Created by Tina  on 9.02.25.
//

import Foundation
import FirebaseFirestore


struct Bank: Identifiable, Codable {
    @DocumentID var id: String? // Automatically generated Firestore document ID
    let name: String
}
