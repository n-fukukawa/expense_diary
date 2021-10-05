//
//  Category.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import RealmSwift

class Category: Object, Identifiable {
    
    @objc dynamic var id = UUID()
    @objc dynamic var type: Int = RecordType.expense.rawValue
    @objc dynamic var name: String = ""
    @objc dynamic var icon: String = ""
    @objc dynamic var order: Int = 0
    @objc dynamic var created_at: Date = Date()   // 作成日
    @objc dynamic var updated_at: Date = Date()   // 更新日
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
//    private static var realm = try! Realm()
//
//    private static var calendar = JPCalendar.getJPCalendar()
    
//    static func all() -> Results<Category> {
//        realm.objects(Category.self)
//    }
    
    static func all() -> Array<Category> {
       return [
            Category(value: ["type" : RecordType.expense.rawValue, "name" : "食費", "icon" : "dish", "order" : 1]),
            Category(value: ["type" : RecordType.expense.rawValue, "name" : "日用品費", "icon" : "laundry.fill", "order" : 2]),
        ]
    }
    
    static func getByType(_ type: RecordType?) -> Array<Category> {
        if(type == .expense) {
            return [
                 Category(value: ["type" : RecordType.expense.rawValue, "name" : "食費", "icon" : "dish", "order" : 1]),
                 Category(value: ["type" : RecordType.expense.rawValue, "name" : "日用品費", "icon" : "laundry.fill", "order" : 2]),
                Category(value: ["type" : RecordType.expense.rawValue, "name" : "交通費", "icon" : "train", "order" : 3]),
                Category(value: ["type" : RecordType.expense.rawValue, "name" : "被服費", "icon" : "fashion", "order" : 4]),
                Category(value: ["type" : RecordType.expense.rawValue, "name" : "美容費", "icon" : "rouge", "order" : 4]),
                Category(value: ["type" : RecordType.expense.rawValue, "name" : "娯楽費", "icon" : "film", "order" : 4]),
                Category(value: ["type" : RecordType.expense.rawValue, "name" : "交際費", "icon" : "present", "order" : 4]),
                Category(value: ["type" : RecordType.expense.rawValue, "name" : "教育費", "icon" : "student", "order" : 4]),
                Category(value: ["type" : RecordType.expense.rawValue, "name" : "医療費", "icon" : "hospital", "order" : 4]),
                Category(value: ["type" : RecordType.expense.rawValue, "name" : "住居費", "icon" : "home", "order" : 4]),
                Category(value: ["type" : RecordType.expense.rawValue, "name" : "水道光熱費", "icon" : "light", "order" : 4]),
             ]
        } else if (type == .income) {
            return [
                Category(value: ["type" : RecordType.income.rawValue, "name" : "給料", "icon" : "money", "order" : 1]),
                Category(value: ["type" : RecordType.income.rawValue, "name" : "賞与", "icon" : "money", "order" : 2]),
            ]
        } else {
            return [Category()]
        }
    }
    
//    static func typeAll(type: ExpenseType) -> Results<Category> {
//        self.all().filter("type = %@", type.rawValue)
//    }
}
