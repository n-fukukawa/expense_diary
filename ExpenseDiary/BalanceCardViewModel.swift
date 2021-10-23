//
//  BalanceCardViewModel.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/23.
//

import Foundation
import RealmSwift
import SwiftUI

final class BalanceCardViewModel: ObservableObject {
    @ObservedObject var env: StatusObject
    @Published var diary: [RecordCell] = []
    
    private var records: Results<Record>
    private var recordCells: [RecordCell] = []
    private var notificationTokens: [NotificationToken] = []
    
    init(env: StatusObject) {
        self.env = env
        self.records = Record.getRecords(start: env.startDate, end: env.endDate)
        
        self.setRecordCells(records: records)
        self.setDiary()
        
        notificationTokens.append(records.observe { change in
            switch change {
                case let .initial(results):
                    self.setRecordCells(records: results)
                    self.setDiary()
                case let .update(results, _, _, _):
                    self.setRecordCells(records: results)
                    self.setDiary()
                case let .error(error):
                    print(error.localizedDescription)
            }
        })
    }
    
    private func setRecordCells(records: Results<Record>) {
        self.recordCells = records.map{RecordCell(id: $0.id, date: $0.date, category: $0.category, amount: $0.amount, memo: $0.memo, created_at: $0.created_at, updated_at: $0.updated_at)}
    }
    
    private func setDiary() {
        self.diary = self.recordCells.sorted{ $0.date > $1.date }
    }

    deinit {
        notificationTokens.forEach { $0.invalidate() }
    }
}
