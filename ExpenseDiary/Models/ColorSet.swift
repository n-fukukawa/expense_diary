//
//  ColorSet.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/23.
//

import RealmSwift
import SwiftUI

class ColorSet: Object, Identifiable {
    
    @objc dynamic var id: Int = 1
    @objc dynamic var name: String = ""
    @objc dynamic var color1: String = ""
    @objc dynamic var color2: String = ""
    @objc dynamic var order: Int = 0
    @objc dynamic var created_at: Date = Date()
    @objc dynamic var updated_at: Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func getColor1() -> Color {
        Color(hex: self.color1)
    }
    
    func getColor2() -> Color {
        Color(hex: self.color2)
    }
    
    private static var realm = try! Realm()

    
    static func seed() {
        try! realm.write {
            let themes = [
                ColorSet(value: ["id" : 1,
                              "name" : "ホライゾンブルー",
                              "color1": "8DC6FA",
                              "color2" : "2878D9",
                              "order" : 1]),
                ColorSet(value: ["id" : 2,
                              "name" : "ファイアレッド",
                              "color1": "ea5532",
                              "color2" : "e8383d",
                              "order" : 2]),
                ColorSet(value: ["id" : 3,
                              "name" : "モスグリーン",
                              "color1": "45ac8d",
                              "color2" : "206d44",
                              "order" : 3]),
            ]
            
            realm.add(themes)
        }
    }
    
    static func all() -> Results<ColorSet> {
        realm.objects(ColorSet.self).sorted(byKeyPath: "id", ascending: true)
    }
    
    static func find(id: Int) -> ColorSet? {
        realm.objects(ColorSet.self).filter("id == %@", id).first
    }
    
    static func standard() -> ColorSet {
        realm.objects(ColorSet.self).first!
    }

}
