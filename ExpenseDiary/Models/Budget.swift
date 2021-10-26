//
//  Budget.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/23.
//

import RealmSwift

class Budget: Object, Identifiable {
    
    @objc dynamic var id = UUID().uuidString
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


    static func seed() {
        try! realm.write {
            let themes = [
                Budget(value: [
                              "year" : 2021,
                              "month" : 10,
                              "category" : Category.getByType(.expense)[2],
                              "amount": 40000,
                            ]),
                Budget(value: [
                              "year" : 2021,
                              "month" : 10,
                              "category" : Category.getByType(.expense)[0],
                              "amount": 10000,
                            ]),
                Budget(value: [
                              "year" : 2021,
                              "month" : 10,
                              "category" : Category.getByType(.expense)[5],
                              "amount": 20000,
                            ]),
            ]
            
            realm.add(themes)
        }
    }
    
    static func all() -> Results<Budget> {
        realm.objects(Budget.self)
            //.sorted(byKeyPath: "category.order", ascending: true)
    }
    
    static func getBudgets(year: Int, month: Int) -> Results<Budget> {
        self.all().filter("year == %@ && month == %@", year, month)
    }
}
