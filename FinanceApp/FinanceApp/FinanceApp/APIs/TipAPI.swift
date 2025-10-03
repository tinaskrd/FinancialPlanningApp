//
//  TipAPI.swift
//  FinanceApp
//
//  Created by Tina  on 13.02.25.
//

import FirebaseFirestore
import FirebaseDatabase


class TipsViewModel: ObservableObject {
    @Published var tips: [FinancialTip] = []
    private var db = Firestore.firestore()

    func fetchTips() {
        db.collection("tips")
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching tips: \(error)")
                    return
                }
                self.tips = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: FinancialTip.self)
                } ?? []
            }
    }
}


