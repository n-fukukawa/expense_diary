//
//  BalanceCardViewModel.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/23.
//

import Foundation
import RealmSwift
import SwiftUI

final class BalanceViewModel: ObservableObject {
    @ObservedObject var env   : StatusObject
    @Published var recordType : RecordType?
    @Published var category   : Category?
    @Published var recordCells: [(key: Date, value: [RecordCell])] = []
    @Published var summary    : [(key: RecordType, value: [(key: Category, value: Int)])] = []
    
    private var notificationTokens: [NotificationToken] = []
    
    init(env: StatusObject) {
        self.env = env
        self.setRecordCells()
        self.setSummary()
        
        notificationTokens.append(Record.all().observe { change in
            switch change {
            case .initial(_):
                self.setRecordCells()
                self.setSummary()
            case  .update(_, _, _, _):
                self.setRecordCells()
                self.setSummary()
            case let .error(error):
                print(error.localizedDescription)
            }
        })
    }
    
    enum BalanceViewState {
        case diary
        case summary
        case category
    }
    
    var viewState: BalanceViewState {
        if self.category == nil && self.recordType == nil {
            return .diary
        }
        if self.category == nil && self.recordType != nil {
            return .summary
        }
        
        return .category
    }
    
    var spending: Int {
        var result = 0
        self.recordCells.forEach({ date, recordCells in
            recordCells.forEach({ recordCell in
                if recordCell.category.type == RecordType.expense.rawValue {
                    result += recordCell.amount
                }
            })
        })
        
        return result
    }
    
    var income: Int {
        var result = 0
        self.recordCells.forEach({ date, recordCells in
            recordCells.forEach({ recordCell in
                if recordCell.category.type == RecordType.income.rawValue {
                    result += recordCell.amount
                }
            })
        })
        
        return result
    }
    
    var balance: Int {
        self.income - self.spending
    }
    
    var categoryAmount: Int {
        var result = 0
        self.recordCells.forEach({ date, recordCells in
            recordCells.forEach({ recordCell in
                result += recordCell.amount
            })
        })
        
        return result
    }
    
    func onChangeCategory(category: Category?) {
        self.category = category
        self.setRecordCells()
        self.setSummary()
    }
    
    func onChangeRecordType(recordType: RecordType?) {
        self.recordType = (self.recordType == recordType) ? nil : recordType
        self.setSummary()
    }
    
    private func setRecordCells() {
        let records = Record.getRecords(start: env.startDate, end: env.endDate, category: self.category)
        
        let cells: [RecordCell] = records.map{RecordCell(id: $0.id, date: $0.date, category: $0.category, amount: $0.amount, memo: $0.memo, created_at: $0.created_at, updated_at: $0.updated_at)}
            .map { recordCell in
                var cell = recordCell
                cell.date = cell.date.fixed(hour: 0, minute: 0, second: 0)
                return cell
            }
            .sorted{ $0.created_at > $1.created_at }
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "md"
        
        self.recordCells = Dictionary(grouping: cells, by: { $0.date }).sorted{$0.key > $1.key}.map{$0}
    }
    
    private func setSummary() {
        if self.viewState == .summary {
            let records = Record.getRecords(start: env.startDate, end: env.endDate)
                            .filter{$0.category.type == self.recordType!.rawValue}
            
            self.summary = Dictionary(grouping: records, by: { RecordType.of($0.category.type) })
                            .mapValues { array -> [(key:Category, value: Int)] in
                                return Dictionary(grouping: array, by: {$0.category})
                                    .mapValues { array -> Int in
                                        var total = 0
                                        array.forEach({ total += $0.amount })
                                        return total
                                    }.sorted{ $0.0.order < $1.0.order }
                                    .map{ $0 }
                            }
                            .sorted{ $0.0.rawValue > $1.0.rawValue }
                            .map{ $0 }
        } else {
            self.summary = []
        }
    }
    
    deinit {
        notificationTokens.forEach { $0.invalidate() }
    }
}
