//
//  ListView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/09.
//

import SwiftUI
import RealmSwift

final class ListViewModel: ObservableObject {
    @ObservedObject var env: StatusObject
    @Published var diary: [(key: Date, value: [RecordCell])] = []
    @Published var summary: [(key: RecordType, value: [(key:Category, value: Int)])] = []
    
    private var records: Results<Record>
    private var recordCells: [RecordCell] = []
    private var notificationTokens: [NotificationToken] = []
    
    init(env: StatusObject) {
        self.env = env
        self.records = Record.getRecords(start: env.startDate, end: env.endDate)
        
        self.setRecordCells(records: records)
        self.setDiary()
        self.setSummary()
        
        notificationTokens.append(records.observe { change in
            switch change {
                case let .initial(results):
                    self.setRecordCells(records: results)
                    self.setDiary()
                    self.setSummary()
                    print("changed")
                case let .update(results, _, _, _):
                    self.setRecordCells(records: results)
                    self.setDiary()
                    self.setSummary()
                    print("update")
                case let .error(error):
                    print(error.localizedDescription)
            }
        })
    }
    
    private func setRecordCells(records: Results<Record>) {
        self.recordCells = records.map{RecordCell(id: $0.id, date: $0.date, category: $0.category, amount: $0.amount, memo: $0.memo, created_at: $0.created_at, updated_at: $0.updated_at)}
    }
    
    private func setDiary() {
        self.diary = Dictionary(grouping: self.recordCells,
                                by: { Calendar.current.startOfDay(for: $0.date)})
                    .sorted{ $0.0 > $1.0 }.map{ $0 }
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

struct ListView: View {
    @ObservedObject var env: StatusObject
    @ObservedObject var viewModel: ListViewModel
    @State var listType: ListType = .records
    
    init(env: StatusObject) {
        self.env = env
        self.viewModel = ListViewModel(env: env)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 0) {
                ForEach(ListType.all(), id: \.self) { listType in
                    Button(action: {
                        self.listType = listType
                    }){
                        let is_active = self.listType == listType
                        VStack(spacing: 8) {
                            if is_active {
                                Text(listType.rawValue).mainStyle(size: 16)
                            } else {
                                Text(listType.rawValue).mainStyle(size: 16)
                            }
                            Rectangle().frame(height: is_active ? 3 : 1).offset(x: 0, y: -1)
                            }
                        }
                        .foregroundColor(.main)
                    }
            }.padding(.horizontal, 20)
            
            switch (listType) {
                case .records : RecordView(viewModel: viewModel)
                case .summary : SummaryView(viewModel: viewModel)
            }
        }
    }
}

struct RecordView: View {
    @ObservedObject var viewModel: ListViewModel
        
    var body: some View {
        VStack {
            if !viewModel.diary.isEmpty {
                ScrollView(showsIndicators: false) {
                    VStack {
                        ForEach(viewModel.diary, id: \.key) { dateRecordCell in
                            DailyCard(date: dateRecordCell.key, recordCells: dateRecordCell.value)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                        }
                    }
                }
            } else {
                NoDataView()
            }
        }
        .onAppear() {
            
        }
    }
}

struct SummaryView: View {
    @ObservedObject var viewModel: ListViewModel
    var expense = 0
    var income = 0
    var balance = 0
    
    init(viewModel: ListViewModel) {
        self.viewModel = viewModel
    
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
                                
                                VStack {
                                    ForEach(summary.value, id: \.key){ item in
                                        ListCard(name: item.key.name, icon: item.key.icon, memo: "", amount: item.value)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                        }
                    }
                }
            } else {
                NoDataView()
            }
        }
    }
}

struct DailyCard: View {
    @State var isShowing = false
    @State var selectedRecordCell: RecordCell?
    let date: Date
    let recordCells: [RecordCell]
    let dateFormatter = DateFormatter()
    var total = 0
    
    init(date: Date, recordCells: [RecordCell]) {
        self.date = date
        self.recordCells = recordCells
        self.dateFormatter.locale = Locale(identifier: "ja_JP")
        self.dateFormatter.dateFormat = "M/d E"
        recordCells.forEach({ recordCell in
            self.total += recordCell.amount * (recordCell.category.type == RecordType.expense.rawValue ? -1 : 1)
        })
    }
    var body: some View {
        VStack(spacing: 5) {
            HStack(spacing: 10) {
                Text("\(dateFormatter.string(from: date))")
                    .planeStyle(size: 16)
                Text("\(total) 円")
                    .planeStyle(size: 12).lineLimit(1)
                Rectangle().frame(height: 1).foregroundColor(.nonActive)
            }
            .foregroundColor(.text)
            .padding(.bottom, 10)
            .padding(.horizontal, 2)
            
            VStack(spacing: 8) {
                ForEach(recordCells.sorted{ $0.created_at > $1.created_at}, id: \.id) { recordCell in
                    Button(action: {
                        self.isShowing = true
                        self.selectedRecordCell = recordCell
                    }) {
                        ListCard(name: recordCell.category.name, icon:recordCell.category.icon, memo: recordCell.memo, amount: recordCell.amount)
                    }
                    .sheet(item: $selectedRecordCell) { recordCell in
                        EditRecordView(record: recordCell)
                    }
                }
            }
        }
    }
}

struct ListCard: View {
    let name: String
    let icon: Icon
    let memo: String
    let amount: Int
    var body: some View {
        ZStack {
            Color.white
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.05), radius: 1, x: 1, y: 1)
            
            HStack {
                Image(icon.name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
                    .foregroundColor(.nonActive)
                    .padding(.trailing, 2)
                
                Text(name).planeStyle(size: 15).lineLimit(1)
                Text(memo).planeStyle(size: 11).lineLimit(1)
                Spacer()
                Text("\(amount) 円").planeStyle(size: 16).lineLimit(1)
            }
            .foregroundColor(.text)
            .padding(.horizontal, 12)
        }
        .frame(height: 44)
    }
}
