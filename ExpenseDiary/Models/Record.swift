//
//  Record.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//


import RealmSwift
import SwiftUI

class Record: Object, Identifiable  {
    @objc dynamic var id = UUID()
    @objc dynamic var date: Date = Date()
    @objc dynamic var type: Int = RecordType.expense.rawValue
    @objc dynamic var category: Category?
    @objc dynamic var amount: Int = 0
    @objc dynamic var memo: String = ""
    @objc dynamic var created_at: Date = Date()
    @objc dynamic var updated_at: Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    private static var realm = try! Realm()
    
    //    static func all() -> Results<Expense> {
    //        realm.objects(Expense.self)
    //    }
    
    static func getDate(day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: 2021, month: 10, day: day))!
    }
    
    static func all(type: RecordType? = nil) -> [Date : Array<Record>] {
        let cate1 = Category(value: ["type" : RecordType.expense.rawValue, "name" : "食費", "icon" : "icon", "order" : 1])
        let cate2 = Category(value: ["type" : RecordType.expense.rawValue, "name" : "日用品費", "icon" : "icon", "order" : 2])
        let cate3 = Category(value: ["type" : RecordType.expense.rawValue, "name" : "交通費", "icon" : "icon", "order" : 3])
        
        return [
            self.getDate(day: 6) : [
                Record(value: [
                    "date": self.getDate(day: 6),
                    "type":RecordType.expense.rawValue,
                    "category": cate3,
                    "amount": 2500,
                    "memo": "京都〜神戸",
                    "created_at": Date(),
                    "updated_at": Date()
                ]),
                
                Record(value: [
                    "date": self.getDate(day: 6),
                    "type":RecordType.expense.rawValue,
                    "category": cate1,
                    "amount": 1000,
                    "memo": "ランチ",
                    "created_at": Date(),
                    "updated_at": Date()
                ]),
                
                Record(value: [
                    "date": self.getDate(day: 6),
                    "type":RecordType.expense.rawValue,
                    "category": cate2,
                    "amount": 280,
                    "memo": "洗剤",
                    "created_at": Date(),
                    "updated_at": Date()
                ]),
            ],
            self.getDate(day: 1) : [
                Record(value: ["date": self.getDate(day: 1),"type":RecordType.expense.rawValue,"category": cate3,"amount":1500,"memo": "大阪〜神戸","created_at": Date(),"updated_at": Date()
                ]),
                Record(value: ["date": self.getDate(day: 1),"type":RecordType.expense.rawValue,"category": cate1,"amount":1000,"memo": "カフェ","created_at": Date(),"updated_at": Date()
                ]),
            ],
        ]
    }
    
    static func getMonthly(type: RecordType?, category: Category?) -> [Date : Array<Record>]? {
        let cate1 = Category(value: ["type" : RecordType.expense.rawValue, "name" : "食費", "icon" : "icon", "order" : 1])
        let cate2 = Category(value: ["type" : RecordType.expense.rawValue, "name" : "日用品費", "icon" : "icon", "order" : 2])
        let cate3 = Category(value: ["type" : RecordType.expense.rawValue, "name" : "交通費", "icon" : "icon", "order" : 3])
        let cateA = Category(value: ["type" : RecordType.income.rawValue, "name" : "給料", "icon" : "icon", "order" : 1])
        let cateB = Category(value: ["type" : RecordType.income.rawValue, "name" : "賞与", "icon" : "icon", "order" : 2])

        if type == nil {
            return self.all()
        }
        
        if let _category = category {
            if _category.name == cate1.name {
                return [
                    self.getDate(day: 6) : [
                        Record(value: ["date": self.getDate(day: 6),"type":RecordType.expense.rawValue,"category": cate1,"amount": 1000,"memo": "ランチ","created_at": Date(),"updated_at": Date()
                        ]),
                    ],
                    self.getDate(day: 1) : [
                        Record(value: ["date": self.getDate(day: 1),"type":RecordType.expense.rawValue,"category": cate1,"amount": 1000,"memo": "カフェ","created_at": Date(),"updated_at": Date()
                        ]),
                    ],
                ]
            } else if _category.name == cate2.name {
                return [
                    self.getDate(day: 6) : [
                        Record(value: ["date": self.getDate(day: 6),"type":RecordType.expense.rawValue,"category": cate2,"amount": 280,"memo": "洗剤","created_at": Date(),"updated_at": Date()
                        ]),
                    ],
                ]
            } else if _category.name == cate3.name {
                return [
                    self.getDate(day: 6) : [
                        Record(value: ["date": self.getDate(day: 6),"type":RecordType.expense.rawValue,"category": cate3,"amount": 2500,"memo": "京都〜神戸","created_at": Date(),"updated_at": Date()
                        ]),
                    ],
                    self.getDate(day: 1) : [
                        Record(value: ["date": self.getDate(day: 1),"type":RecordType.expense.rawValue,"category": cate3,"amount":1500,"memo": "大阪〜神戸","created_at": Date(),"updated_at": Date()
                        ]),
                    ]
                ]
            } else if _category.name == cateA.name {
                return [
                    self.getDate(day: 25) : [
                        Record(value: ["date": self.getDate(day: 25),"type":RecordType.income.rawValue,"category": cateA,"amount": 250000,"memo": "テスト株式会社","created_at": Date(),"updated_at": Date()
                        ]),
                    ],
                ]
            } else if _category.name == cateB.name {
                return [
                    self.getDate(day: 15) : [
                        Record(value: ["date": self.getDate(day: 15),"type":RecordType.income.rawValue,"category": cateB,"amount":500000,"memo": "秋のボーナス","created_at": Date(),"updated_at": Date()
                        ]),
                    ]
                ]
            } else {
                return nil
            }
        }
        
        return nil
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
