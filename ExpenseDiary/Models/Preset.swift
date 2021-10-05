//
//  Preset.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//


import RealmSwift
import SwiftUI

class Preset: Object, Identifiable  {
    
    @objc dynamic var id = UUID()
    @objc dynamic var category: Category?
    @objc dynamic var amount: Int = 0
    @objc dynamic var memo: String = ""
    @objc dynamic var created_at: Date = Date()
    @objc dynamic var updated_at: Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    private static var realm = try! Realm()
    
    static func all() -> Array<Preset> {
        let cate1 = Category(value: ["type" : RecordType.expense.rawValue, "name" : "食費", "icon" : "icon", "order" : 1])
        let cate2 = Category(value: ["type" : RecordType.expense.rawValue, "name" : "日用品費", "icon" : "icon", "order" : 2])
        let cate3 = Category(value: ["type" : RecordType.expense.rawValue, "name" : "交通費", "icon" : "icon", "order" : 3])
        
        return [
                Preset(value: [
                    "category": cate3,
                    "amount": 2500,
                    "memo": "京都〜神戸",
                    "created_at": Date(),
                    "updated_at": Date()
                ]),
                Preset(value: [
                    "category": cate1,
                    "amount": 3500,
                    "memo": "お米",
                    "created_at": Date(),
                    "updated_at": Date()
                ]),
        ]
    }

    
    
    static func create(date: Date, type:String, category: Category, amount: Int, memo: String, created_at: Date, updated_at: Date) {
        try! realm.write {
            let newExpense = Record(value: [
                "date":date,
                "type":type,
                "category":category,
                "amount":amount,
                "memo":memo,
                "created_at":created_at,
                "updated_at":updated_at
            ])
            realm.add(newExpense)
        }
    }
    
    static func update(record: Record, date: Date, type:String, category: Category?, amount: Int, memo: String, updated_at: Date) {
        try! realm.write {
            record.setValue(date, forKey: "date")
            record.setValue(type, forKey: "type")
            record.setValue(category, forKey: "category")
            record.setValue(amount, forKey: "amount")
            record.setValue(memo, forKey: "memo")
            record.setValue(updated_at, forKey: "updated_at")
        }
    }
    
    static func delete(_ expense: Record) {
        try! realm.write {
            realm.delete(expense)
        }
    }
    
}
