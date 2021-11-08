//
//  CalcKey.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/11/06.
//

import Foundation

enum CalcKey: String {
    
    case equal  = "="
    case plus   = "+"
    case minus  = "−"
    case times  = "×"
    case divide = "÷"
    
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case zero = "0"
    
    case clear = "C"
    case percent = "%"
    case inverse = "+/−"
    case delete = "←"
    
    case period = "."
    
    static func operands() -> [CalcKey] {
        [.plus, .minus, .times, .divide, .equal]
    }
    
    static func numbers() -> [CalcKey] {
        [.one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .zero]
    }
    
    static func all() -> [CalcKey] {
        [
            .clear, .percent, .inverse, .delete,
            .seven, .eight, .nine, .divide,
            .four, .five, .six, .times,
            .one, .two, .three, .minus,
            .zero, .period, .equal, .plus
        ]
    }
    
}
