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
    
    static func seed() {
        let icons = [
            Icon(value: ["name" : "all", "code" : 100001, "selectable" : 0]),
            
            Icon(value: ["name" : "dish", "code" : 201001]),
            Icon(value: ["name" : "restaurant", "code" : 201002]),
            Icon(value: ["name" : "cake", "code" : 201003]),
            
            Icon(value: ["name" : "laundry.fill", "code" : 202001]),
            
            Icon(value: ["name" : "t-shirt", "code" : 203001]),
            Icon(value: ["name" : "dress", "code" : 203002]),
            Icon(value: ["name" : "fashion", "code" : 203003]),
            Icon(value: ["name" : "rouge", "code" : 203004]),
            
            Icon(value: ["name" : "bicycle", "code" : 301001]),
            Icon(value: ["name" : "bike", "code" : 301002]),
            Icon(value: ["name" : "car", "code" : 301003]),
            Icon(value: ["name" : "train", "code" : 301004]),
            Icon(value: ["name" : "airplane", "code" : 301005]),

            Icon(value: ["name" : "book", "code" : 302001]),
            Icon(value: ["name" : "golf", "code" : 302002]),
            Icon(value: ["name" : "bara", "code" : 302003]),
            Icon(value: ["name" : "music", "code" : 302004]),
            Icon(value: ["name" : "film", "code" : 302005]),
            Icon(value: ["name" : "camera", "code" : 302006]),
            Icon(value: ["name" : "travel", "code" : 302007]),
            Icon(value: ["name" : "present", "code" : 302008]),
            
            Icon(value: ["name" : "hospital", "code" : 303001]),
            Icon(value: ["name" : "medicine", "code" : 303002]),
            
            Icon(value: ["name" : "school", "code" : 304001]),
            Icon(value: ["name" : "student", "code" : 304002]),
            
            Icon(value: ["name" : "phone", "code" : 305001]),
            Icon(value: ["name" : "pc", "code" : 305002]),
            Icon(value: ["name" : "web", "code" : 305003]),
            
            Icon(value: ["name" : "bird", "code" : 306001]),
            Icon(value: ["name" : "cat", "code" : 306002]),
            Icon(value: ["name" : "dog", "code" : 306003]),
            Icon(value: ["name" : "horse", "code" : 306004]),
            
            Icon(value: ["name" : "light", "code" : 401001]),
            Icon(value: ["name" : "water", "code" : 401002]),
            
            Icon(value: ["name" : "home", "code" : 402001]),
            Icon(value: ["name" : "home2", "code" : 402002]),
            
            Icon(value: ["name" : "pen", "code" : 901001]),
            Icon(value: ["name" : "heart", "code" : 902001]),
            Icon(value: ["name" : "spade", "code" : 902002]),
            Icon(value: ["name" : "diamond", "code" : 902003]),
            Icon(value: ["name" : "clover", "code" : 902004]),
            Icon(value: ["name" : "star", "code" : 902005]),
           
            Icon(value: ["name" : "spending", "code" : 903001]),
            Icon(value: ["name" : "money", "code" : 903002]),
            Icon(value: ["name" : "save", "code" : 903003]),
            Icon(value: ["name" : "wallet", "code" : 903004]),
            Icon(value: ["name" : "yen", "code" : 903005]),
            Icon(value: ["name" : "nasu", "code" : 903006]),
        ]
        
        try! realm.write {
            realm.add(icons)
        }
    }
    
    static func all() -> Results<Icon> {
        realm.objects(Icon.self).filter("selectable == 1").sorted(byKeyPath: "code", ascending: true)
    }
    
    static func find(_ name: String) -> Icon? {
        realm.objects(Icon.self).filter("name == %@", name).first
    }

}
