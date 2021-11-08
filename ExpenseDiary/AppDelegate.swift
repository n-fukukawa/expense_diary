//
//  AppDelegate.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/11/07.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        Batch.presetBatch()
        
        return true
    }
}
