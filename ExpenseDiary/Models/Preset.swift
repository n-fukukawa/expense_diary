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
    @objc dynamic var category: Category!
    @objc dynamic var amount: Int = 0
    @objc dynamic var memo: String = ""
    @objc dynamic var order: Int = 1
    @objc dynamic var created_at: Date = Date()
    @objc dynamic var updated_at: Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    private static var realm = try! Realm()
    
    static func all() -> Results<Preset> {
        self.realm.objects(Preset.self).sorted(byKeyPath: "order", ascending: true)
    }
    
    static func create(category: Category, amount: Int, memo: String) -> Preset {
        try! realm.write {
            let newPreset = Preset(value: [
                "category":category,
                "amount":amount,
                "memo":memo,
                "created_at":Date(),
                "updated_at":Date()
            ])
            realm.add(newPreset)
            return newPreset
        }
    }
    
    static func update(preset: Preset, category: Category, amount: Int, memo: String) -> Preset {
        try! realm.write {
            preset.setValue(category, forKey: "category")
            preset.setValue(amount,   forKey: "amount")
            preset.setValue(memo,     forKey: "memo")
            preset.setValue(Date(),   forKey: "updated_at")
            
            return preset
        }
    }
    
    static func updateOrder(preset: Preset, order: Int) {
        try! realm.write {
            preset.setValue(order, forKey: "order")
        }
    }
    
    static func delete(_ preset: Preset) {
        try! realm.write {
            realm.delete(preset)
        }
    }
    
    static func deleteByCategory(_ category: Category) {
        try! realm.write {
            let presets = realm.objects(Preset.self).filter("category = %@", category)
            realm.delete(presets)
        }
    }
    
    static func getById(_ id: UUID) -> Preset? {
        return self.realm.objects(Preset.self).filter("id == %@", id).first
    }
    
    static func getMaxOrder() -> Int {
        self.realm.objects(Preset.self).value(forKeyPath: "@max.order")! as! Int
    }
}
