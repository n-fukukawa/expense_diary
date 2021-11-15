//
//  Budget.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/23.
//

import RealmSwift

class Budget: Object, Identifiable {
    
    @objc dynamic var id = UUID()
    @objc dynamic var year: Int = 0
    @objc dynamic var month: Int = 0
    @objc dynamic var category: Category!
    @objc dynamic var amount: Int = 0
    @objc dynamic var created_at: Date = Date()
    @objc dynamic var updated_at: Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    private static var realm = try! Realm()
    
    static func all() -> Results<Budget> {
        realm.objects(Budget.self)
            .sorted(byKeyPath: "category.order", ascending: true)
    }
    
    static func getBudgets(year: Int, month: Int) -> Results<Budget> {
        self.all().filter("year == %@ && month == %@", year, month)
            .filter("amount > 0")
    }
    
    static func create(year: Int, month: Int, category: Category, amount: Int) -> Budget {
        try! realm.write {
            let budget = Budget(value: [
                "year": year,
                "month": month,
                "category": category,
                "amount": amount,
            ])
            realm.add(budget)
            
            return budget
        }
    }
    
    static func update(budget: Budget, year: Int, month: Int, category: Category, amount: Int)
        -> Budget {
            try! realm.write {
                budget.setValue(year, forKey: "year")
                budget.setValue(month, forKey: "month")
                budget.setValue(category, forKey: "category")
                budget.setValue(amount, forKey: "amount")
                budget.setValue(Date(), forKey: "updated_at")
            }
            
            return budget
    }
    
    
    static func creates(budgets: [Budget]) {
        try! realm.write {
            realm.add(budgets)
        }
    }
    
    static func updates(budgetCells: [BudgetCell]) {
        try! realm.write {
            budgetCells.forEach({ budgetCell in
                if let storedBudget = Budget.getById(budgetCell.id) {
                    storedBudget.amount = budgetCell.amount
                    storedBudget.updated_at = Date()
                }
            })
        }
    }

    
    static func delete(_ budget: Budget) {
        try! realm.write {
            realm.delete(budget)
        }
    }
    
    // カテゴリーが削除されることによる予算の削除
    static func deleteByCategory(_ category: Category) {
        try! realm.write {
            let budgets = realm.objects(Budget.self).filter("category = %@", category)
            realm.delete(budgets)
        }
    }
    
    static func getById(_ id: UUID) -> Budget? {
        return self.realm.objects(Budget.self).filter("id == %@", id).first
    }
}
