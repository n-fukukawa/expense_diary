//
//  ExpenseDiaryApp.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import SwiftUI

@main
struct ExpenseDiaryApp: App {
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(StatusObject())
        }
    }
}
