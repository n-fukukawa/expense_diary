//
//  ViewType.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import Foundation

enum ViewType: String {
    case home
    case balance
    case budget
    case analysis
    case settingBudget
    case settingCategory
    case settingPreset
    case settingCalendarTheme
    
    static func settings() -> [ViewType] {
        return [
            .settingBudget, .settingCategory, .settingPreset, .settingCalendarTheme
        ]
    }
}
