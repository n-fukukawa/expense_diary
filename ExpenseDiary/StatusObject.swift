//
//  StatusObject.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import Foundation
import RealmSwift
import SwiftUI

class StatusObject: ObservableObject {
    let year  = Calendar.current.component(.year, from: Date())
    let month = Calendar.current.component(.month, from: Date())
    let day   = Calendar.current.component(.day, from: Date())
    
    @Published var viewType: ViewType = .home // home/balance/budget/analysis
    
    @Published var mode: ViewMode = .home // home/chart
    @Published var activeYear: Int = 0
    @Published var activeMonth: Int = 0
    
//    @Published var showYearMonthPicker = false
    
    
    @Published var startDay: Int {
        didSet {
            UserDefaults.standard.set(startDay, forKey: "startDay")
        }
    }
    
    @Published var startWeekday: Int {
        didSet {
            UserDefaults.standard.set(startWeekday, forKey: "startWeekday")
        }
    }
    
    @Published var forward: Int {
        didSet {
            UserDefaults.standard.set(forward, forKey: "forward")
        }
    }
    
    @Published var themeId: Int {
        didSet {
            UserDefaults.standard.set(themeId, forKey: "themeId")
        }
    }

    init() {
        UserDefaults.standard.register(defaults: ["startDay" : 1,
                                                  "startWeekday" : 1,
                                                  "forward"  : 0,
                                                  "themeId"  : 1])
        self.startDay     = UserDefaults.standard.integer(forKey: "startDay")
        self.startWeekday = UserDefaults.standard.integer(forKey: "startWeekday")
        self.forward      = UserDefaults.standard.integer(forKey: "forward")
        self.themeId      = UserDefaults.standard.integer(forKey: "themeId")

        self.refreshActive()
    }
    
    var startDateYear: Int {
        Calendar.current.component(.year, from: self.startDate)
    }
    
    var startDate: Date {
        if forward == 1 {
            return Calendar.current.date(from: DateComponents(year: self.activeYear, month: activeMonth - 1, day: startDay))!
        } else {
            return Calendar.current.date(from: DateComponents(year: self.activeYear, month: activeMonth, day: startDay))!
        }
    }
    
    var endDate: Date {
        if forward == 1 {
            return Calendar.current.date(from: DateComponents(year: self.activeYear, month: activeMonth, day: startDay - 1))!
        } else {
            return Calendar.current.date(from: DateComponents(year: self.activeYear, month: activeMonth + 1, day: startDay - 1))!
        }
    }
    
    func getStartAndEndDate(year: Int, month: Int) -> [Date] {
        let start: Date
        let end:   Date
        
        if forward == 1 {
            start = Calendar.current.date(from: DateComponents(year: year, month: month - 1, day: startDay))!
        } else {
            start = Calendar.current.date(from: DateComponents(year: year, month: month, day: startDay))!
        }
        
        if forward == 1 {
            end = Calendar.current.date(from: DateComponents(year: year, month: month, day: startDay - 1))!
        } else {
            end = Calendar.current.date(from: DateComponents(year: year, month: month + 1, day: startDay - 1))!
        }
        
        return [start, end]
    }
    
    

    func refreshActive() {        
        let date: Date
        
        if startDay == 1 {
            forward = 0
        }
        
        if day >= startDay {
            if forward == 1 {
                date = Calendar.current.date(from: DateComponents(year: year, month: month + 1))!
            } else {
                date = Calendar.current.date(from: DateComponents(year: year, month: month))!
            }
        } else {
            if forward == 1 {
                date = Calendar.current.date(from: DateComponents(year: year, month: month))!
            } else {
                date = Calendar.current.date(from: DateComponents(year: year, month: month - 1))!
            }
        }
        
        self.activeYear = Calendar.current.component(.year, from: date)
        self.activeMonth = Calendar.current.component(.month, from: date)
    }
    
    
    func setActive(year: Int, month: Int) {
        let date = Calendar.current.date(from: DateComponents(year: year, month: month))!

        self.activeYear = Calendar.current.component(.year, from: date)
        self.activeMonth = Calendar.current.component(.month, from: date)
    }
    
    func movePrevMonth() {
        if self.activeMonth == 1 {
            self.activeYear -= 1
            self.activeMonth = 12
        } else {
            self.activeMonth -= 1
        }
    }
    
    func moveNextMonth() {
        if self.activeMonth == 12 {
            self.activeYear += 1
            self.activeMonth = 1
        } else {
            self.activeMonth += 1
        }
    }
    
    func onChangeViewType(_ viewType: ViewType) {
        self.viewType = viewType
    }
}
