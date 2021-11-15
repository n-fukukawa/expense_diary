//
//  Category.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import RealmSwift
import SwiftUI

class Category: Object, Identifiable {
    
    @objc dynamic var id = UUID()
    @objc dynamic var type: Int = RecordType.expense.rawValue
    @objc dynamic var name: String = ""
    @objc dynamic var icon: Icon!
    @objc dynamic var order: Int = 1
    @objc dynamic var total: Int = 0
    @objc dynamic var created_at: Date = Date()
    @objc dynamic var updated_at: Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    private static var realm = try! Realm()
    
    static func all(withTotal: Bool = false) -> Results<Category> {
        let sortProperties = [
          SortDescriptor(keyPath: "type", ascending: true),
          SortDescriptor(keyPath: "order", ascending: true)
        ]
        
        if withTotal {
            return self.realm.objects(Category.self).sorted(by: sortProperties)
        }
        
        return self.realm.objects(Category.self).filter("total != 1").sorted(by: sortProperties)
    }
    
    static func getByType(_ type: RecordType, withTotal: Bool = false) -> Results<Category> {
        return self.all(withTotal: withTotal)
            .filter("type == %@", type.rawValue)
            .sorted(byKeyPath: "order", ascending: true)
    }
    
    static func create(type: RecordType, name: String, icon: Icon) -> Category {
        try! realm.write {
            let order = self.getMaxOrder() + 1
            let category = Category(value: ["type" : type.rawValue, "name" : name, "icon" : icon, "order": order])
            realm.add(category)
            
            return category
        }
    }
    
    static func update(category: Category, name: String, icon: Icon) -> Category {
        try! realm.write {
            category.setValue(name, forKey: "name")
            category.setValue(icon, forKey: "icon")
            
            return category
        }
    }
    
    static func updateOrder(category: Category, order: Int) {
        category.setValue(order, forKey: "order")
    }
    
    static func delete(_ category: Category) {
        Preset.deleteByCategory(category)
        Budget.deleteByCategory(category)
        Record.deleteByCategory(category)
        try! realm.write {
            realm.delete(category)
        }
    }
    
    static func getById(_ id: UUID) -> Category? {
        return self.realm.objects(Category.self).filter("id == %@", id).first
    }
    
    static func getMaxOrder() -> Int {
        self.realm.objects(Category.self).value(forKeyPath: "@max.order")! as! Int
    }
}
