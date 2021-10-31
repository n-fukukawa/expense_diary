//
//  CategoryViewModel.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/29.
//

import SwiftUI
import RealmSwift

class CategoryViewModel: ObservableObject {
    @Published var categoryCells: [CategoryCell] = []
    
    private var categories: Results<Category>
    private var notificationTokens: [NotificationToken] = []
    
    init() {
        self.categories = Category.all()
        self.setCategoryCells(categories: categories)
        
        notificationTokens.append(categories.observe { change in
            switch change {
                case let .initial(results):
                    self.setCategoryCells(categories: results)
                case let .update(results, _, _, _):
                    self.setCategoryCells(categories: results)
                case let .error(error):
                    print(error.localizedDescription)
            }
        })
    }
    
    private func setCategoryCells(categories: Results<Category>) {
        self.categoryCells = CategoryCell.generateCategoryCell(categories: categories)
    }
    
    func filterCategoryCells(type: RecordType) -> [CategoryCell] {
        self.categoryCells.filter{$0.type == type.rawValue}
    }
    
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
    
    func delete(categoryCell: CategoryCell?) {
        if let categoryCell = categoryCell {
            if let category = Category.getById(categoryCell.id) {
                Category.delete(category)
            }
        }
    }
    
    func move(type: RecordType, _ from: IndexSet, _ to: Int) {
        let categories = self.filterCategoryCells(type: type)
        guard let source = from.first else {
            return
        }
        
        if source < to {
            for i in (source + 1)...(to - 1) {
                if let category = Category.getById(categories[i].id) {
                    Category.updateOrder(category: category, order: i)
                }
            }
            if let category = Category.getById(categories[source].id) {
                Category.updateOrder(category: category, order: to)
            }
        } else if source > to {
            var count = 0
            for i in (to...(source - 1)).reversed() {
                if let category = Category.getById(categories[i].id) {
                    Category.updateOrder(category: category, order: source + 1 - count)
                }
                count += 1
            }
            if let category = Category.getById(categories[source].id) {
                Category.updateOrder(category: category, order: to + 1)
            }
        }
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
