//
//  BudgetCell.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/24.
//

import Foundation
import RealmSwift

struct BudgetCell: Identifiable, Hashable {
    let id: UUID
    let year: Int
    let month: Int
    let category: Category
    var amount: Int
    let created_at: Date
    let updated_at: Date
    
    var show = false
    
    static func generateFromBudget(budgets: Results<Budget>) -> [BudgetCell] {
        return budgets.map{BudgetCell(id: $0.id, year: $0.year, month: $0.month, category: $0.category, amount: $0.amount, created_at: $0.created_at, updated_at: $0.updated_at)}
    }
}
