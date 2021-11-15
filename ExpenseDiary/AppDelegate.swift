//
//  AppDelegate.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/11/07.
//

import SwiftUI
import RealmSwift

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        self.makeInitialDatabase()
        
        Batch.presetBatch()
        
        return true
    }
    
    private func makeInitialDatabase() {
        let defaultRealmPath = Realm.Configuration.defaultConfiguration.fileURL!

        if !FileManager.default.fileExists(atPath: defaultRealmPath.path) {
          do {
            let bundleRealmPath = Bundle.main.url(forResource: "initial", withExtension: "realm")
            try FileManager.default.copyItem(at: bundleRealmPath!, to: defaultRealmPath)
          } catch let error {
              print("error: \(error)")
            }
        }
    }
}

