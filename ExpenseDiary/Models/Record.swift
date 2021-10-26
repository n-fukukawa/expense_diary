//
//  Record.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//


import RealmSwift
import SwiftUI

class Record: Object, Identifiable  {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var date: Date = Date()
    @objc dynamic var category: Category!
    @objc dynamic var amount: Int = 0
    @objc dynamic var memo: String = ""
    @objc dynamic var created_at: Date = Date()
    @objc dynamic var updated_at: Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
//
//    var identity: String {
//        return isInvalidated ? "deleted-object-\(UUID().uuidString)" : id
//    }
    
    private static var realm = try! Realm()
    
    
    static func all() -> Results<Record> {
        self.realm.objects(Record.self)
    }
    
    static func getRecords(start: Date, end: Date, category: Category? = nil) -> Results<Record> {
        var records = self.realm.objects(Record.self).filter("date BETWEEN {%@, %@}", start, end)
                
        if let category = category {
            records = records.filter("category == %@", category)
        }
        
        return records.sorted(byKeyPath: "date", ascending: false)
    }
    
    static func getRecords(start: Date, end: Date, type: RecordType) -> Results<Record> {
        return self.realm.objects(Record.self)
            .filter("date BETWEEN {%@, %@} && category.type == %@", start, end, type.rawValue)
    }
    
    static func create(date: Date, category: Category, amount: Int, memo: String) -> Record {
        try! realm.write {
            let record = Record(value: [
                "date":date,
                "category":category,
                "amount":amount,
                "memo":memo
            ])
            realm.add(record)
            
            return record
        }
    }
    
    static func update(record: Record, date: Date, category: Category, amount: Int, memo: String)
        -> Record {
            try! realm.write {
                record.setValue(date, forKey: "date")
                record.setValue(category, forKey: "category")
                record.setValue(amount, forKey: "amount")
                record.setValue(memo, forKey: "memo")
                record.setValue(Date(), forKey: "updated_at")
            }
            
            return record
    }
    
    static func delete(_ record: Record) {
        try! realm.write {
            realm.delete(record)
        }
    }
    
    static func deleteByCategory(_ category: Category) {
        try! realm.write {
            let records = realm.objects(Record.self).filter("category = %@", category)
            realm.delete(records)
        }
    }

    
    static func getById(_ id: String) -> Record? {
        return self.realm.objects(Record.self).filter("id == %@", id).first
    }
    
    
    static func seed() {
        var records:[Record] = []
        for i in 1...3000 {
            for j in 1...50 {
                records.append(Record(value: [
                                        "date"     : Calendar.current.date(byAdding: .day, value: -i, to: Date())!,
                                        "category" : Category.all()[j % 9],
                                        "amount"   : 1458,
                                        "memo"     : "テスト"
                ]))
            }
        }
        try! realm.write {
            realm.add(records)
        }
    }
    
}
