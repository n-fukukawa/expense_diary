//
//  RecordType.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import Foundation

enum RecordType: Int {
    case expense = 1
    case income  = 2
    
    static func all() -> Array<RecordType> {
        return [self.expense, self.income]
    }
    
    static func of(_ value: Int) -> RecordType {
        switch(value) {
            case 1: return .expense
            case 2: return .income
            default: return .expense
        }
    }
    
    var name: String {
        switch self {
        case .expense: return "支出"
        case .income : return "収入"
        }
    }
}
