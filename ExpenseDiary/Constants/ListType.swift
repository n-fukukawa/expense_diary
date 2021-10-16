//
//  TabItem.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import Foundation

enum ListType: String {
    case records = "記録"
    case summary = "収支"
    
    static func all() -> Array<ListType> {
        return [
            self.records, self.summary
        ]
    }
}
