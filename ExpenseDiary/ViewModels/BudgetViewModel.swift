//
//  BudgetViewModel.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/24.
//

import Foundation
import RealmSwift
import SwiftUI

final class BudgetViewModel: ObservableObject {
    @ObservedObject var env: StatusObject
    @Published var active: Bool = false
    @Published var budgetCells: [BudgetCell] = []
    @Published var recordCells: [BudgetCell : [(key: Date, value: [RecordCell])]] = [:]
    
    private var budgets = Budget.all()
    private var records = Record.all()
    
    private var notificationTokens: [NotificationToken] = []
    
    init(env: StatusObject) {
        self.env = env
        self.setBudgetCells()
        self.setRecordCells()

        notificationTokens.append(Budget.all().observe { change in
            switch change {
                case .initial(_):
                    self.setBudgetCells()
                case .update(_, _, _, _):
                    self.setBudgetCells()
                case let .error(error):
                    print(error.localizedDescription)
            }
        })
        
        notificationTokens.append(Record.all().observe { change in
            switch change {
                case .initial(_):
                    self.setRecordCells()
                case .update(_, _, _, _):
                    self.setRecordCells()
                case let .error(error):
                    print(error.localizedDescription)
            }
        })
    }
    
    enum BudgetViewState {
        case all
        case select
    }
    
    var viewState: BudgetViewState {
        if self.active {
            return .select
        } else {
            return .all
        }
    }
    
    func getSpending(budgetCell: BudgetCell) -> Int {
        var result = 0
        self.getRecords(budgetCell: budgetCell).forEach({recordCell in
            result += recordCell.amount
        })
        
        return result
    }
    
//    func activation(_ bool : Bool) {
//        self.active = bool
//        self.setRecordCells()
//    }
//    
    private func setBudgetCells() {
        let budgets = Budget.getBudgets(year: env.activeYear, month: env.activeMonth)
        self.budgetCells = BudgetCell.generateFromBudget(budgets: budgets)
    }
    
    private func setRecordCells() {
            self.budgetCells.forEach({ budgetCell in
                let recordCells: [RecordCell] = self.getRecords(budgetCell: budgetCell)
                    .map{RecordCell(id: $0.id, date: $0.date, category: $0.category, amount: $0.amount, memo: $0.memo, created_at: $0.created_at, updated_at: $0.updated_at)}
                    .map { recordCell in
                        var cell = recordCell
                        cell.date = cell.date.fixed(hour: 0, minute: 0, second: 0)
                        return cell
                    }
                    .sorted{ $0.created_at > $1.created_at }
            
                self.recordCells.updateValue(
                    Dictionary(grouping: recordCells, by: { $0.date }).sorted{$0.key > $1.key}.map{$0}, forKey: budgetCell)
            })
    }
    
    private func getRecords(budgetCell: BudgetCell) -> Results<Record> {
        let date = env.getStartAndEndDate(year: budgetCell.year, month: budgetCell.month)
        
        if budgetCell.category.total == 1 {
            return Record.getRecords(start: date[0], end: date[1], type: .expense)
        } else {
            return Record.getRecords(start: date[0], end: date[1], category: budgetCell.category)
        }
    }

    deinit {
        notificationTokens.forEach { $0.invalidate() }
    }
}
