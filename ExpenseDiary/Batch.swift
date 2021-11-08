//
//  Batch.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/11/07.
//

import Foundation

class Batch {
    static func presetBatch() {
        let presets = Preset.getshouldUpdatePresets()
        presets.forEach{ preset in
            var date: Date
            if let latestDate = preset.latestDate {
                date = latestDate.added(month: 1)
            } else {
                date = preset.created_at.fixed(day: preset.day).getStartOfDay()
            }
            while date <= Date().getEndOfDay() {
                _ = Record.create(date: date, category: preset.category, amount: preset.amount, memo: preset.memo)
                _ = Preset.updateLatestDate(preset: preset, date: date)
                date = date.added(month: 1)
            }
        }
    }
}
