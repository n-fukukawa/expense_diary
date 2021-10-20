//
//  Category.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import RealmSwift

class Category: Object, Identifiable {
    
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var type: Int = RecordType.expense.rawValue
    @objc dynamic var name: String = ""
    @objc dynamic var icon: Icon!
    @objc dynamic var order: Int = 1
    @objc dynamic var created_at: Date = Date()   // 作成日
    @objc dynamic var updated_at: Date = Date()   // 更新日
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    private static var realm = try! Realm()
    
    static func seed() {
        let categories = [
            Category(value: ["type" : RecordType.expense.rawValue, "name" : "食費", "icon" : Icon.find("dish")!, "order" : 1]),
            Category(value: ["type" : RecordType.expense.rawValue, "name" : "日用品費", "icon" : Icon.find("laundry.fill")!, "order" : 2]),
           Category(value: ["type" : RecordType.expense.rawValue, "name" : "交通費", "icon" : Icon.find("train")!, "order" : 3]),
           Category(value: ["type" : RecordType.expense.rawValue, "name" : "被服費", "icon" : Icon.find("fashion")!, "order" : 4]),
           Category(value: ["type" : RecordType.expense.rawValue, "name" : "美容費", "icon" : Icon.find("rouge")!, "order" : 5]),
           Category(value: ["type" : RecordType.expense.rawValue, "name" : "娯楽費", "icon" : Icon.find("film")!, "order" : 6]),
           Category(value: ["type" : RecordType.expense.rawValue, "name" : "交際費", "icon" : Icon.find("present")!, "order" : 7]),
           Category(value: ["type" : RecordType.expense.rawValue, "name" : "教育費", "icon" : Icon.find("student")!, "order" : 8]),
           Category(value: ["type" : RecordType.expense.rawValue, "name" : "医療費", "icon" : Icon.find("hospital")!, "order" : 9]),
           Category(value: ["type" : RecordType.expense.rawValue, "name" : "住居費", "icon" : Icon.find("home")!, "order" : 10]),
           Category(value: ["type" : RecordType.expense.rawValue, "name" : "水道光熱費", "icon" : Icon.find("light")!, "order" : 11]),
           Category(value: ["type" : RecordType.income.rawValue, "name" : "給料", "icon" : Icon.find("money")!, "order" : 1]),
           Category(value: ["type" : RecordType.income.rawValue, "name" : "賞与", "icon" : Icon.find("money")!, "order" : 2])
        ]
        
        try! realm.write {
            realm.add(categories)
        }
    }
    
    static func all() -> Results<Category> {
        return self.realm.objects(Category.self).sorted(byKeyPath: "order", ascending: true)
    }
    
    static func getByType(_ type: RecordType) -> Results<Category> {
        return self.realm.objects(Category.self)
            .filter("type == %@", type.rawValue)
            .sorted(byKeyPath: "order", ascending: true)
    }
    
    static func create(type: RecordType, name: String, icon: Icon) -> Category {
        try! realm.write {
            let order = self.getMaxOrder() + 1
            print(order)
            let category = Category(value: ["type" : type.rawValue, "name" : name, "icon" : icon, "order": order])
            print(category)
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
        try! realm.write {
            category.setValue(order, forKey: "order")
        }
    }
    
    static func delete(_ category: Category) {
        Record.deleteByCategory(category)
        Preset.deleteByCategory(category)
        try! realm.write {
            realm.delete(category)
        }
    }
    
    static func getById(_ id: String) -> Category? {
        return self.realm.objects(Category.self).filter("id == %@", id).first
    }
    
    static func getMaxOrder() -> Int {
        self.realm.objects(Category.self).value(forKeyPath: "@max.order")! as! Int
    }
}
