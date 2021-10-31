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
    @objc dynamic var order: Int = 0
    @objc dynamic var created_at: Date = Date()
    @objc dynamic var updated_at: Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    private static var realm = try! Realm()
    
    static func seed() {
        let icons = [
            Icon(value: ["name" : "airplane", "order" : 1]),
            Icon(value: ["name" : "bara", "order" : 1]),
            Icon(value: ["name" : "bicycle", "order" : 1]),
            Icon(value: ["name" : "bike", "order" : 1]),
            Icon(value: ["name" : "book", "order" : 1]),
            Icon(value: ["name" : "dish", "order" : 1]),
            Icon(value: ["name" : "dress", "order" : 1]),
            Icon(value: ["name" : "fashion", "order" : 1]),
            Icon(value: ["name" : "film", "order" : 1]),
            Icon(value: ["name" : "home", "order" : 1]),
            Icon(value: ["name" : "home2", "order" : 1]),
            Icon(value: ["name" : "hospital", "order" : 1]),
            Icon(value: ["name" : "laundry.fill", "order" : 1]),
            Icon(value: ["name" : "laundry", "order" : 1]),
            Icon(value: ["name" : "light", "order" : 1]),
            Icon(value: ["name" : "money", "order" : 1]),
            Icon(value: ["name" : "pen", "order" : 1]),
            Icon(value: ["name" : "phone", "order" : 1]),
            Icon(value: ["name" : "present", "order" : 1]),
            Icon(value: ["name" : "rouge", "order" : 1]),
            Icon(value: ["name" : "school", "order" : 1]),
            Icon(value: ["name" : "student", "order" : 1]),
            Icon(value: ["name" : "train", "order" : 1]),
            Icon(value: ["name" : "web", "order" : 1]),
        ]
        
        try! realm.write {
            realm.add(icons)
        }
    }
    
    static func all() -> Results<Icon> {
        realm.objects(Icon.self)
    }
    
    static func find(_ name: String) -> Icon? {
        realm.objects(Icon.self).filter("name == %@", name).first
    }

}
