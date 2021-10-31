//
//  CategoryCell.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/15.
//

import Foundation
import RealmSwift

struct CategoryCell: Identifiable, Hashable {
    let id: UUID
    let type: Int
    let name: String
    let icon: Icon!
    let order: Int
    let created_at: Date
    let updated_at: Date
    
    static func generateCategoryCell(categories: Results<Category>) -> [CategoryCell] {
        return categories.map {
                CategoryCell(id: $0.id, type: $0.type, name: $0.name, icon: $0.icon, order: $0.order, created_at: $0.created_at, updated_at: $0.updated_at)
                }
    }
}
