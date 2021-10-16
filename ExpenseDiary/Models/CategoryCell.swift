//
//  CategoryCell.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/15.
//

import Foundation

struct CategoryCell: Identifiable {
    let id: String
    let type: Int
    let name: String
    let icon: Icon!
    let order: Int
    let created_at: Date
    let updated_at: Date
}
