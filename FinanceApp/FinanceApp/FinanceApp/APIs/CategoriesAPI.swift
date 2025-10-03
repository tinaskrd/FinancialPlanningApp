//
//  CategoriesAPI.swift
//  FinanceApp
//
//  Created by Tina  on 17.02.25.
//

import Foundation
import SwiftUI

class CategoriesAPI: ObservableObject {
    @Published var categories: [String] = []
    
    func fetchCategories() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.categories = ["Grocery Store", "Restaurants", "Transport", "Entertainment", "Shopping", "Bills", "Healthcare"]
        }
    }
}

