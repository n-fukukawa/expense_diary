//
//  StatusObject.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import Foundation

class StatusObject: ObservableObject {
    let settingDay = 25
    let forward    = true
    @Published var navItem: GlobalNavItem = .list
    @Published var activeYear: Int = 0
    @Published var activeMonth: Int = 0
    
    var startDateYear: Int {
        Calendar.current.component(.year, from: self.startDate)
    }
    
    var startDate: Date {
        if forward {
            return Calendar.current.date(from: DateComponents(year: self.activeYear, month: activeMonth - 1, day: settingDay))!
        } else {
            return Calendar.current.date(from: DateComponents(year: self.activeYear, month: activeMonth, day: settingDay))!
        }
    }
    
    var endDate: Date {
        if forward {
            return Calendar.current.date(from: DateComponents(year: self.activeYear, month: activeMonth, day: settingDay - 1))!
        } else {
            return Calendar.current.date(from: DateComponents(year: self.activeYear, month: activeMonth + 1, day: settingDay - 1))!
        }
    }
    
    init() {
        let year  = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        let day   = Calendar.current.component(.day, from: Date())
        
        let _date: Date
        
        if day >= settingDay {
            if forward {
                _date = Calendar.current.date(from: DateComponents(year: year, month: month + 1))!
            } else {
                _date = Calendar.current.date(from: DateComponents(year: year, month: month))!
            }
        } else {
            if forward {
                _date = Calendar.current.date(from: DateComponents(year: year, month: month))!
            } else {
                _date = Calendar.current.date(from: DateComponents(year: year, month: month - 1))!
            }
        }
        
        self.activeYear = Calendar.current.component(.year, from: _date)
        self.activeMonth = Calendar.current.component(.month, from: _date)
    }
    
    
    func addMonth() {
        let _date = Calendar.current.date(from: DateComponents(year: activeYear, month: activeMonth + 1))!

        self.activeYear = Calendar.current.component(.year, from: _date)
        self.activeMonth = Calendar.current.component(.month, from: _date)
    }
}
