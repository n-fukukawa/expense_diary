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
        self.categoryCells = categories.map {
                CategoryCell(id: $0.id, type: $0.type, name: $0.name, icon: $0.icon, order: $0.order, created_at: $0.created_at, updated_at: $0.updated_at)
                }
    }
    
    func filterCategoryCells(type: RecordType) -> [CategoryCell] {
        self.categoryCells.filter{$0.type == type.rawValue}
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
        
        let realm = try! Realm()
        
        try! realm.write {
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
        self.setCategoryCells(categories: self.categories)
    }
}


