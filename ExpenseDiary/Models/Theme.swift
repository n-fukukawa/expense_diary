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
    @objc dynamic var colorSetLight: String = ""
    @objc dynamic var colorSetDark: String = ""
    @objc dynamic var order: Int = 0
    @objc dynamic var created_at: Date = Date()
    @objc dynamic var updated_at: Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    private static var realm = try! Realm()
    
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
