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
    @Published var activeBudget: BudgetCell?
    @Published var budgetCells: [BudgetCell] = []
    @Published var recordCells: [BudgetCell : [RecordCell]] = [:]
    
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
//                    self.setBudgetCells()
                    self.setRecordCells()
                case .update(_, _, _, _):
//                    self.setBudgetCells()
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
        if self.activeBudget == nil {
            return .all
        } else {
            return .select
        }
    }
    
    func getSpending(budgetCell: BudgetCell) -> Int {
        var result = 0
        self.getRecords(budgetCell: budgetCell).forEach({recordCell in
            result += recordCell.amount
        })
        
        return result
    }
    
    func onSelectBudget(budgetCell: BudgetCell) {
        self.activeBudget = budgetCell
        self.setRecordCells()
    }
    
    private func setBudgetCells() {
        let budgets = Budget.getBudgets(year: env.activeYear, month: env.activeMonth)
        self.budgetCells = BudgetCell.generateFromBudget(budgets: budgets)
    }
    
    private func setRecordCells() {
            self.budgetCells.forEach({ budgetCell in
                let recordCells = self.getRecords(budgetCell: budgetCell)
                    .map{RecordCell(id: $0.id, date: $0.date, category: $0.category, amount: $0.amount, memo: $0.memo, created_at: $0.created_at, updated_at: $0.updated_at)}
            
                self.recordCells.updateValue(Array(recordCells), forKey: budgetCell)
            })
    }
    
    private func getRecords(budgetCell: BudgetCell) -> Results<Record> {
        let date = env.getStartAndEndDate(year: budgetCell.year, month: budgetCell.month)
        
        return Record.getRecords(start: date[0], end: date[1], category: budgetCell.category)
    }

    deinit {
        notificationTokens.forEach { $0.invalidate() }
    }
}
