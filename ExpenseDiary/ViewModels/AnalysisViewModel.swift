//
//  AnalysisViewModel.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/24.
//

import Foundation
import RealmSwift
import SwiftUI
import Charts

final class AnalysisViewModel: ObservableObject {
    @ObservedObject var env: StatusObject
    
    @Published var monthlyAmounts: [(key: YearMonth, value: Int)] = []
    @Published var recordType: RecordType?
    @Published var category: Category?
    var viewState: AnalysisViewState = .balance
    
    private var notificationTokens: [NotificationToken] = []
    
    init(env: StatusObject) {
        self.env = env
        self.setmonthlyAmounts()
        
        
        notificationTokens.append(Record.all().observe { change in
            switch change {
                case .initial(_):
                    self.setmonthlyAmounts()
                case .update(_, _, _, _):
                    self.setmonthlyAmounts()
                case let .error(error):
                    print(error.localizedDescription)
            }
        })
    }
    
    
    enum AnalysisViewState {
        case total
        case balance
        case category
    }
    
    
    func onChangeCategory(category: Category?) {
        if category != nil {
            self.viewState = .category
        }
        self.category = category
        self.recordType = nil
        self.setmonthlyAmounts()
    }
    
    func onChangeRecordType(recordType: RecordType?) {
        if recordType != nil {
            self.viewState = .total
        }
        self.recordType = recordType
        self.category = nil
        self.setmonthlyAmounts()
    }
    
    func onClickBalance() {
        self.viewState = .balance
        self.category = nil
        self.recordType = nil
        self.setmonthlyAmounts()
    }
    
    private func setmonthlyAmounts() {
        var yearMonths: [YearMonth] = []
        for i in 0...12 {
            if env.activeMonth - i <= 0 {
                yearMonths.append(YearMonth(year: env.activeYear - 1, month: 12 + (env.activeMonth - i)))
            } else {
                yearMonths.append(YearMonth(year: env.activeYear, month: env.activeMonth - i))
            }
        }
        
        var result:[(key: YearMonth, value: Int)] = []
        yearMonths.forEach({ yearMonth in
            let startAndEndDate = env.getStartAndEndDate(year: yearMonth.year, month: yearMonth.month)
            
            var records: Results<Record>
            if self.viewState == .category{
                records = Record.getRecords(start: startAndEndDate[0], end: startAndEndDate[1], category: category)
            } else if self.viewState == .total {
                records = Record.getRecords(start: startAndEndDate[0], end: startAndEndDate[1], type: self.recordType!)
            } else {
                records = Record.getRecords(start: startAndEndDate[0], end: startAndEndDate[1])
            }
            
            var sum = 0
            if self.viewState == .balance {
                records.forEach({ record in
                    sum += record.amount * (record.category.type == RecordType.expense.rawValue ? -1 : 1)
                })
            } else {
                records.forEach({ record in
                    sum += record.amount
                })
            }

            
            result.append((key: yearMonth, value: sum))
        })
        
        self.monthlyAmounts = result
    }
    
//    func getDataSet(category: Category?, recordType: RecordType?) -> [(key: YearMonth, value: Int)] {
//        var yearMonths: [YearMonth] = []
//        
//        for i in 0...5 {
//            yearMonths.append(YearMonth(year: env.activeYear, month: env.activeMonth - i))
//        }
//        
//        var result:[(key: YearMonth, value: Int)] = []
//        yearMonths.forEach({ yearMonth in
//            let startAndEndDate = env.getStartAndEndDate(activeYear: yearMonth.year, activeMonth: yearMonth.month)
//            var records: Results<Record>
//            
//            if let category = category {
//                records = self.records.filter("category == %@ && date >= %@  && date <= %@", category, startAndEndDate[0], startAndEndDate[1])
//            } else if let recordType = recordType {
//                records = self.records.filter("category.type == %@ && date >= %@  && date <= %@", recordType.rawValue, startAndEndDate[0], startAndEndDate[1])
//            } else {
//                records = self.records
//            }
//            
//            var sum = 0
//            records.forEach({ record in
//                sum += record.amount
//            })
//            
//            result.append((key: yearMonth, value: sum))
//        })
//        
//        return result
//    }

//    
//    func getAmount(category: Category) -> Int {
//        var result = 0
//        self.recordCells.filter{$0.category == category}.forEach({ record in
//            result += record.amount
//        })
//        
//        return result
//    }
//    
//    private func setRecordCells(records: Results<Record>) {
//        self.recordCells = records.map{RecordCell(id: $0.id, date: $0.date, category: $0.category, amount: $0.amount, memo: $0.memo, created_at: $0.created_at, updated_at: $0.updated_at)}
//    }

    deinit {
        notificationTokens.forEach { $0.invalidate() }
    }
}
