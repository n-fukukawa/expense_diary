//
//  RecordType.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import Foundation
import SwiftUI

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
    
    var colorSet: ColorSet {
        switch self {
            case .expense: return ColorSet(value: ["id" : 1,
                                    "name" : "ホライゾンレッド",
                                    "color1": "ea44a0",
                                    "color2" : "ce2235",
                                    "order" : 1])
                
            case .income:  return ColorSet(value: ["id" : 1,
                                   "name" : "ホライゾンブルー",
                                   "color1": "a0d8ea",
                                   "color2" : "35a0ce",
                                   "order" : 1])
        }
    }
    
    var color1: Color {
        Color(hex: self.colorSet.color1)
    }
    
    var color2: Color {
        Color(hex: self.colorSet.color2)
    }
}
