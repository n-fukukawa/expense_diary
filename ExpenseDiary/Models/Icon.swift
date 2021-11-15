//
//  Icon.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/15.
//

import RealmSwift

class Icon: Object, Identifiable {
    
    @objc dynamic var id = UUID()
    @objc dynamic var name: String = ""
    @objc dynamic var code: Int = 0
    @objc dynamic var selectable: Int = 1
    @objc dynamic var created_at: Date = Date()
    @objc dynamic var updated_at: Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    private static var realm = try! Realm()
    
    static func all() -> Results<Icon> {
        realm.objects(Icon.self).filter("selectable == 1").sorted(byKeyPath: "code", ascending: true)
    }
    
    static func find(_ name: String) -> Icon? {
        realm.objects(Icon.self).filter("name == %@", name).first
    }

}
