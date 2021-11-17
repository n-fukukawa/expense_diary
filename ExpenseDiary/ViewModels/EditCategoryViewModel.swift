//
//  EditCategoryViewModel.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/11/17.
//

import Foundation

class EditCategoryViewModel: ObservableObject {
    func save(categoryCell: CategoryCell?, type: RecordType, name: String, icon: Icon?)
        -> Result<Category, EditCategoryError>
    {
        // バリデーション
        if name.isEmpty {
            return .failure(.nameIsEmpty)
        }
        if name.count > Config.CATEGORY_NAME_MAX  {
            return .failure(.nameTooLong)
        }
        guard let icon = icon else {
            return .failure(.iconIsEmpty)
        }
        
        // 更新
        if let categoryCell = categoryCell {
            if let category = Category.getById(categoryCell.id) {
                let updateCategory = Category.update(category: category, name: name, icon: icon)
                return .success(updateCategory)
            }
            
            return .failure(.categoryNotFound)
        }
        
        // 新規作成
        let category = Category.create(type: type, name: name, icon: icon)

        return .success(category)
    }

}

enum EditCategoryError : Error {
    case nameIsEmpty
    case nameTooLong
    case iconIsEmpty
    case categoryNotFound
    
    var message: String {
        switch self {
        case .nameIsEmpty       : return "カテゴリー名を入力してください"
        case .nameTooLong       : return "カテゴリー名は\(Config.CATEGORY_NAME_MAX)文字以内で入力してください"
        case .iconIsEmpty       : return "アイコンを選択してください"
        case .categoryNotFound  : return "カテゴリーがみつかりませんでした"
        }
    }
}
