//
//  EditRecordViewModel.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/29.
//

import SwiftUI

class EditRecordViewModel: ObservableObject {
    
    func save(recordCell: RecordCell?, date: Date, category: Category?, amount: String, memo: String)
        -> Result<Record, EditRecordError>
    {
        // バリデーション
        guard let category = category else {
            return .failure(.categoryIsEmpty)
        }
        if amount.isEmpty {
            return .failure(.amountIsEmpty)
        }
        guard let amount = Int(amount) else {
            return .failure(.amountNotNumeric)
        }
        if amount < 0  {
            return .failure(.amountNotNumeric)
        }
        if memo.count > Config.RECORD_MEMO_MAX  {
            return .failure(.memoTooLong)
        }
        
        // 更新
        if let recordCell = recordCell {
            if let record = Record.getById(recordCell.id) {
                let updatedRecord = Record.update(record: record, date: date, category: category, amount: amount, memo: memo)
                return .success(updatedRecord)
            }
            
            return .failure(.recordNotFound)
        }
        
        // 新規作成
        let record = Record.create(date: date, category: category, amount: amount, memo: memo)

        return .success(record)
    }
    
    func delete(recordCell: RecordCell?) {
        if let recordCell = recordCell {
            if let record = Record.getById(recordCell.id) {
                Record.delete(record)
            }
        }
    }
}

enum EditRecordError : Error {
    case amountIsEmpty
    case amountNotNumeric
    case categoryIsEmpty
    case memoTooLong
    case recordNotFound
    
    var message: String {
        switch self {
        case .amountIsEmpty     : return "金額を入力してください"
        case .amountNotNumeric  : return "金額には正の整数を入力してください"
        case .categoryIsEmpty   : return "カテゴリーを選択してください"
        case .memoTooLong       : return "メモは\(Config.RECORD_MEMO_MAX)文字以内で入力してください"
        case .recordNotFound    : return "記録がみつかりませんでした"
        }
    }
}
