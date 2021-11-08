//
//  EditBudgetViewModel.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/29.
//

import SwiftUI

class EditBudgetViewModel: ObservableObject {
    @ObservedObject var env: StatusObject
    @Published var categoryCells: [CategoryCell] = []
    @Published var budgetCells: [BudgetCell] = []
    
    init(env: StatusObject) {
        self.env = env
        self.categoryCells = Category.getByType(.expense)
            .map {
                CategoryCell(id: $0.id, type: $0.type, name: $0.name, icon: $0.icon, order: $0.order, created_at: $0.created_at, updated_at: $0.updated_at)
                }
        
        let budgets = Budget.getBudgets(year: self.env.activeYear, month: self.env.activeMonth)
        self.budgetCells = BudgetCell.generateFromBudget(budgets: budgets)
    }
    
    func save(amounts: [(key: CategoryCell, value: String)], year: Int, month: Int)
        -> Result<[Budget], EditBudgetError>
    {
        var errors: [EditBudgetError] = []
        var updates: [BudgetCell] = []
        var creates: [Budget] = []
        
        amounts.forEach({ categoryCell, amount in
            // Update

            if let budgetCell = self.budgetCells.filter({$0.category.id == categoryCell.id}).first {
                var amount = amount
                
                if amount.isEmpty {
                    amount = "0"
                }
                
                guard let amount = Int(amount) else {
                    errors.append(.amountNotNumeric)
                    return
                }
                if amount < 0  {
                    errors.append(.amountNotNumeric)
                    return
                }
                
                var budgetCell = budgetCell
                budgetCell.amount = amount
                updates.append(budgetCell)
                
            // Create
            } else {
                if !amount.isEmpty {
                    guard let amount = Int(amount) else {
                        errors.append(.amountNotNumeric)
                        return
                    }
                    
                    if amount < 0  {
                        errors.append(.amountNotNumeric)
                        return
                    }
                    
                    if let category = Category.getById(categoryCell.id) {
                        let budget = Budget(value: ["year" : self.env.activeYear, "month" : self.env.activeMonth, "category" : category, "amount" : amount])

                        creates.append(budget)
                    }
                }
            }
        })
        
        
        if let error = errors.first {
            return .failure(error)
        } else {
            Budget.updates(budgetCells: updates)
            Budget.creates(budgets: creates)
            return .success([])
        }
    }
    
    func delete(budgetCell: BudgetCell?) {
        if let budgetCell = budgetCell {
            if let budget = Budget.getById(budgetCell.id) {
                Budget.delete(budget)
            }
        }
    }
}

enum EditBudgetError : Error {
    case amountNotNumeric
    case categoryIsEmpty
    case budgetNotFound
    
    var message: String {
        switch self {
        case .amountNotNumeric  : return "予算には正の整数を入力してください"
        case .categoryIsEmpty   : return "カテゴリーを選択してください"
        case .budgetNotFound    : return "予算がみつかりませんでした"
        }
    }
}
