//
//  TabItem.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import Foundation

enum TabItem: String {
    case expense = "支出"
    case balance = "収支"
    case income  = "収入"
    
    static func all() -> Array<TabItem> {
        return [
            self.expense, self.balance, self.income
        ]
    }
    
    var type: RecordType? {
        switch self {
        case .expense:  return .expense
        case .balance:  return nil
        case .income:   return .income
        }
    }
}
