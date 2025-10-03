//
//  UserModel.swift
//  FinanceApp
//
//  Created by Tina  on 19.02.25.
//

import FirebaseFirestore
import FirebaseAuth

struct UserModel: Identifiable, Codable {
    var id: String
    var bank: String
    var email: String
    var createdAt: Date
}

