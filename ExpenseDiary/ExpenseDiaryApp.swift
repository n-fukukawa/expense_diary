//
//  ExpenseDiaryApp.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import SwiftUI

@main
struct ExpenseDiaryApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(StatusObject())
        }
    }
}
