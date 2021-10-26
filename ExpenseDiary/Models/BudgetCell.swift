//
//  BudgetCell.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/24.
//

import Foundation

struct BudgetCell: Identifiable {
    let id: String
    let year: Int
    let month: Int
    let category: Category
    let amount: Int
    let created_at: Date
    let updated_at: Date
}
