//
//  RecordCell.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/14.
//

import Foundation

struct RecordCell: Identifiable {
    let id: UUID
    var date: Date
    let category: Category!
    let amount: Int
    let memo: String
    let created_at: Date
    let updated_at: Date
    
    public static func getSum(_ recordCells: [RecordCell]) -> Int {
        var sum = 0
        recordCells.forEach({ recordCell in
            if recordCell.category.type == RecordType.expense.rawValue {
                sum -= recordCell.amount
            } else {
                sum += recordCell.amount
            }
        })
        
        return sum
    }
}
