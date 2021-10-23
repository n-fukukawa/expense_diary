//
//  Budget.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/23.
//

import RealmSwift

class Budget: Object, Identifiable {
    
    @objc dynamic var id: Int = 1
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
                Budget(value: ["id" : 1,
                              "year" : 2021,
                              "month" : 10,
                              "category" : Category.getByType(.expense)[3],
                              "amount": 20000,
                            ]),
                Budget(value: ["id" : 2,
                              "year" : 2021,
                              "month" : 10,
                              "category" : Category.getByType(.expense)[2],
                              "amount": 30000,
                            ]),
                Budget(value: ["id" : 3,
                              "year" : 2021,
                              "month" : 10,
                              "category" : Category.getByType(.expense)[1],
                              "amount": 30000,
                            ]),
            ]
            
            realm.add(themes)
        }
    }
    
    static func all() -> Results<Budget> {
        realm.objects(Budget.self).sorted(byKeyPath: "id", ascending: true)
    }
    
    static func find(id: Int) -> Budget? {
        realm.objects(Budget.self).filter("id == %@", id).first
    }
}
