//
//  CalendarViewModel.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/31.
//

import SwiftUI
import RealmSwift

final class CalendarViewModel: ObservableObject {
    @ObservedObject var env: StatusObject
    @Published var amounts: [(key: Date, value: [RecordType : Int])] = []
    
    let weeks = ["日", "月", "火", "水", "木", "金", "土"]
    
    var dates: [Date] = []
    
    private var notificationTokens: [NotificationToken] = []
    
    init(env: StatusObject) {
        self.env = env
        self.setAmounts()
        
        notificationTokens.append(Record.all().observe { change in
            switch change {
            case .initial(_):
                self.setAmounts()
            case .update(_, _, _, _):
                self.setAmounts()
            case let .error(error):
                print(error.localizedDescription)
            }
        })
    }
    
    private func setAmounts() {
        let dates = self.generateCalendar()
        
        var amounts: [(key: Date, value: [RecordType : Int])] = []
        dates.forEach({ date in
            let amount = Record.getEachAmount(start: date, end: date)
            amounts.append((key: date, value: amount))
        })
        
        self.amounts = amounts
    }
    
    func generateCalendar() -> [Date] {
        let weekdayOfStartDate = self.env.startDate.weekday
        let startOffset = (weekdayOfStartDate - self.env.startWeekday + 7) % 7
        
        let weekdayOfEndDate = self.env.endDate.weekday
        let endOffset = 6 - (weekdayOfEndDate - self.env.startWeekday + 7) % 7
        
        let startDate = self.env.startDate.added(day: -startOffset)
        let endDate   = self.env.endDate.added(day: endOffset)
        
        var dates:[Date] = []
        
        var date = startDate
        while date <= endDate {
            dates.append(date)
            date = date.added(day: 1)
        }
        
        return dates
    }
    
    func getCalendarHeader() -> [String] {
        var a : [String] = []
        for num in 0...6 {
            let index = (self.env.startWeekday + 6 + num) % 7
            a.append(weeks[index])
        }
        return a
    }


    public func isSameMonth(_ date : Date) -> Bool {
        date >= self.env.startDate && date <= self.env.endDate
    }
    
    deinit {
        notificationTokens.forEach { $0.invalidate() }
    }
}


