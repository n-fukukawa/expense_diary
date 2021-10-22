//
//  ContentType.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import Foundation
import SwiftUI

enum ContentType: String {
    case records = "List"
    case summary = "Balance"
    case chart   = "Chart"
    
    static func all() -> Array<ContentType> {
        return [
            self.records, self.summary, self.chart
        ]
    }
    
    var corner: [UIRectCorner] {
        switch self {
            case .records: return [.topLeft]
            case .summary: return [.topLeft]
            case .chart:   return [.topRight]
        }
    }
    
    var icon: String {
        switch self {
            case .records: return "list.bullet"
            case .summary: return "list.bullet"
            case .chart:   return "chart.bar.xaxis"
        }
    }
}
