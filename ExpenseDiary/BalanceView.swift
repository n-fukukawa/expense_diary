//
//  BalanceView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/09.
//

import SwiftUI
import RealmSwift

final class SummaryViewModel: ObservableObject {
    @ObservedObject var env: StatusObject
    @Published var summary: [(key: RecordType, value: [(key:Category, value: Int)])] = []
    
    private var records: Results<Record>
    private var recordCells: [RecordCell] = []
    private var notificationTokens: [NotificationToken] = []
    
    init(env: StatusObject) {
        self.env = env
        self.records = Record.getRecords(start: env.startDate, end: env.endDate)
        
        self.setRecordCells(records: records)
        self.setSummary()
        
        notificationTokens.append(records.observe { change in
            switch change {
                case let .initial(results):
                    self.setRecordCells(records: results)
                    self.setSummary()
                case let .update(results, _, _, _):
                    self.setRecordCells(records: results)
                    self.setSummary()
                case let .error(error):
                    print(error.localizedDescription)
            }
        })
    }
    
    private func setRecordCells(records: Results<Record>) {
        self.recordCells = records.map{RecordCell(id: $0.id, date: $0.date, category: $0.category, amount: $0.amount, memo: $0.memo, created_at: $0.created_at, updated_at: $0.updated_at)}
    }
    
    private func setSummary() {
        self.summary = Dictionary(grouping: self.recordCells,
                                  by: { RecordType.of($0.category.type) })
                        .mapValues { array -> [(key:Category, value: Int)] in
                            return Dictionary(grouping: array,
                                              by: {$0.category})
                                .mapValues { array -> Int in
                                            var total = 0
                                            array.forEach({ total += $0.amount })
                                            return total
                                }.sorted{ $0.0.order < $1.0.order }
                                .map{ $0 }
                            }
                        .sorted{ $0.0.rawValue > $1.0.rawValue }
                        .map{ $0 }
    }
    

    deinit {
        notificationTokens.forEach { $0.invalidate() }
    }
}


struct SummaryView: View {
    @ObservedObject var env: StatusObject
    @ObservedObject var viewModel: SummaryViewModel
    var expense = 0
    var income = 0
    var balance = 0
    
    init(env: StatusObject) {
        self.env = env
        self.viewModel = SummaryViewModel(env: env)
    
        if !self.viewModel.summary.isEmpty {
            self.viewModel.summary.forEach({ type, dict in
                dict.forEach( {
                    category, value in
                        if type == RecordType.expense {
                            self.expense += value
                        } else if type == RecordType.income {
                            self.income += value
                        }
                })
            })
            
            self.balance = self.income - self.expense
        }
    }
    
    var body: some View {
        VStack (spacing: 0) {
            if !viewModel.summary.isEmpty {
                HStack {
                    if balance > 0 {
                        Text("+ \(balance) 円").planeStyle(size: 20)
                    } else {
                        Text("− \(abs(balance)) 円").warningStyle(size: 20)
                    }
                }
                .padding(.bottom, 16)
                
                ScrollView {
                    VStack (spacing: 20) {
                        ForEach(viewModel.summary, id: \.key) { summary in
                            VStack {
                                HStack(spacing: 10) {
                                    Text("\(summary.key.name)")
                                        .planeStyle(size: 16)
                                        .foregroundColor(.text)
                                    Text("\(summary.key == .expense ? expense : income) 円")
                                        .planeStyle(size: 14)
                                        .lineLimit(1)
                                        .foregroundColor(.text)
                                    Rectangle().frame(height: 1).foregroundColor(.nonActive)
                                }
                                .padding(.horizontal, 2)
                                
                                VStack (spacing: 14) {
                                    ForEach(summary.value, id: \.key){ item in
                                        ListCard(name: item.key.name, icon: item.key.icon, memo: "", amount: item.value)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                        }
                    }
                    .padding(.bottom, 45)
                }
            } else {
                NoDataView()
            }
        }

    }
}
