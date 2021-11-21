//
//  PresetViewModel.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/11/07.
//

import Foundation
import SwiftUI
import RealmSwift


class PresetViewModel: ObservableObject {
    @Published var presetCells: [PresetCell] = []
    @Published var categoryCells: [CategoryCell] = []
    
    private var presets: Results<Preset>
    private var notificationTokens: [NotificationToken] = []
    
    init() {
        self.presets = Preset.all()
        self.setPresetCells(presets: self.presets)
        self.setCategoryCells(categories: Category.all())
        
        notificationTokens.append(presets.observe { change in
            switch change {
                case let .initial(results):
                    self.setPresetCells(presets: results)
                case let .update(results, _, _, _):
                    self.setPresetCells(presets: results)
                case let .error(error):
                    print(error.localizedDescription)
            }
        })
    }
    
    private func setPresetCells(presets: Results<Preset>) {
        self.presetCells = presets.sorted{ $0.category.order < $1.category.order }.map {
            PresetCell(id: $0.id, day: $0.day, category: $0.category, amount: $0.amount, memo: $0.memo, created_at: $0.created_at, updated_at: $0.updated_at)
        }
    }
    
    private func setCategoryCells(categories: Results<Category>) {
        self.categoryCells = CategoryCell.generateCategoryCell(categories: categories)
    }
    
    func getPresetCells(type: RecordType) -> [(key: Int, value: [PresetCell])] {
        let cells = self.presetCells.filter{$0.category.type == type.rawValue}
        return Dictionary(grouping: cells, by: {$0.day}).sorted{$0.key < $1.key}.map{ $0 }
    }
    
    func getCategoryCells(type: RecordType) -> [CategoryCell] {
        return self.categoryCells.filter{$0.type == type.rawValue}.map{$0}
    }
    
    func save(presetCell: PresetCell?, categoryCell: CategoryCell?, day: Int, amount: String, memo: String)
        -> Result<Preset, EditPresetError>
    {
        var amount = amount
        
        // バリデーション
        guard let categoryCell = categoryCell else {
            return .failure(.categoryIsEmpty)
        }
        if amount.isEmpty {
            amount = "0"
        }
        guard let amount = Int(amount) else {
            return .failure(.amountNotNumeric)
        }
        if amount < 0  {
            return .failure(.amountNotNumeric)
        }
        
        let category = Category.getById(categoryCell.id)!
        
        // 更新
        if let presetCell = presetCell {
            if let preset = Preset.getById(presetCell.id) {
                let updatePreset = Preset.update(preset: preset, day: day, category: category, amount: amount, memo: memo)
                
                Batch.presetBatch()
                return .success(updatePreset)
            }
            
            return .failure(.presetNotFound)
        }
        
        // 新規作成
        let preset = Preset.create(day: day, category: category, amount: amount, memo: memo)

        Batch.presetBatch()
        return .success(preset)
    }
    
    func delete(presetCell: PresetCell?) {
        if let presetCell = presetCell {
            if let preset = Preset.getById(presetCell.id) {
                Preset.delete(preset)
            }
        }
    }
}

enum EditPresetError : Error {
    case categoryIsEmpty
    case bothEmpty
    case amountNotNumeric
    case memoTooLong
    case presetNotFound
    
    var message: String {
        switch self {
        case .categoryIsEmpty  : return "カテゴリーを選択してください"
        case .bothEmpty        : return "金額またはメモのどちらかは入力してください"
        case .amountNotNumeric : return "金額には正の整数を入力してください"
        case .memoTooLong      : return "メモは\(Config.RECORD_MEMO_MAX)文字以内で入力してください"
        case .presetNotFound   : return "固定収支がみつかりませんでした"
        }
    }
}
