//
//  Category.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import RealmSwift

class Theme: Object, Identifiable {
    
    @objc dynamic var id: Int = 1
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
    
    private static var realm = try! Realm()
//
//    private static var calendar = JPCalendar.getJPCalendar()
    
//    static func all() -> Results<Category> {
//        realm.objects(Category.self)
//    }
    
    static func seed() {
        try! realm.write {
            let themes = [
                Theme(value: ["id" : 1,
                              "name" : "シチリア",
                              "color1": "fcfcfc",
                              "color2" : "89baca",
                              "color3" : "e3c342",
                              "order" : 1]),
                Theme(value: ["id" : 2,
                              "name" : "ヴォルケイノ",
                              "color1": "202020",
                              "color2" : "A7170B",
                              "color3" : "DB9800",
                              "order" : 2]),
            ]
            
            realm.add(themes)
        }
    }
    
    static func all() -> Results<Theme> {
        realm.objects(Theme.self).sorted(byKeyPath: "id", ascending: true)
    }
    
    static func find(id: Int) -> Theme? {
        realm.objects(Theme.self).filter("id == %@", id).first
    }
    
    static func standard() -> Theme {
        realm.objects(Theme.self).first!
    }

}
