//
//  RecordCell.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/14.
//

import Foundation

struct RecordCell: Identifiable {
    let id: String
    let date: Date
    let category: Category!
    let amount: Int
    let memo: String
    let created_at: Date
    let updated_at: Date
}
