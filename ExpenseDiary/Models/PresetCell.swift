//
//  PresetCell.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/15.
//

import Foundation

struct PresetCell: Identifiable {
    let id: String
    let category: Category!
    let amount: Int
    let memo: String
    let order: Int
    let created_at: Date
    let updated_at: Date
}
