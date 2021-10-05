//
//  StatusObject.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import Foundation

class StatusObject: ObservableObject {
    @Published var tabItem: TabItem = .expense
    @Published var navItem: GlobalNavItem = .list
    @Published var category: Category? = nil
}
