//
//  Category.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import RealmSwift

class Theme: Object, Identifiable {
    
    @objc dynamic var id = UUID()
    @objc dynamic var name: String = ""
    @objc dynamic var color1: String = ""
    @objc dynamic var color2: String = ""
    @objc dynamic var color3: String = ""
    @objc dynamic var color4: String = ""
    @objc dynamic var color5: String = ""
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
    
    static func all() -> Array<Theme> {
       return [
        Theme(value: ["name" : "シチリア","color1": "fcfcfc", "color2" : "89baca", "color3" : "e3c342", "order" : 1]),
        Theme(value: ["name" : "ヴォルケイノ", "color1": "202020", "color2" : "A7170B", "color3" : "DB9800", "order" : 2]),
        ]
    }

}
