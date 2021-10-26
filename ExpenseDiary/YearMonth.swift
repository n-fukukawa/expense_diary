//
//  YearMonth.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/24.
//

import Foundation

final class YearMonth: Identifiable {
    var id = UUID()
    var year: Int
    var month: Int
    
    init (year: Int, month: Int) {
        self.year = year
        self.month = month
    }
    
    
    var fullDesc: String {
        "\(self.year)年\(self.month)月"
    }
    
    var monthDesc: String {
        "\(self.month)月"
    }
}
