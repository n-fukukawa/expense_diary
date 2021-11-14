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
        self.diary = Dictionary(grouping: self.recordCells,
                                by: { Calendar.current.startOfDay(for: $0.date)})
                    .sorted{ $0.0 > $1.0 }.map{ $0 }
    }

    deinit {
        notificationTokens.forEach { $0.invalidate() }
    }
}

struct ListView: View {
    @ObservedObject var env: StatusObject
    @ObservedObject var viewModel: ListViewModel
    
    init(env: StatusObject) {
        self.env = env
        self.viewModel = ListViewModel(env: env)
    }
    
    var body: some View {
        VStack {
            if !viewModel.diary.isEmpty {
                ScrollView(showsIndicators: false) {
                    VStack {
                        ForEach(viewModel.diary, id: \.key) { dateRecordCell in
                            DailyCard(date: dateRecordCell.key, recordCells: dateRecordCell.value)
                               // .padding(.leading, 8)
                                .padding(.vertical, 16)
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

struct DailyCard: View {
    let screen = UIScreen.main.bounds
    @State var isShowing = false
    @State var selectedRecordCell: RecordCell?
    let date: Date
    let recordCells: [RecordCell]
    let dayFormat  = DateFormatter()
    let weekFormat = DateFormatter()
    var total = 0
    
    init(date: Date, recordCells: [RecordCell]) {
        self.date = date
        self.recordCells = recordCells
        self.dayFormat.locale = Locale(identifier: "ja_JP")
        self.dayFormat.dateFormat = "d"
        self.weekFormat.locale = Locale(identifier: "ja_JP")
        self.weekFormat.dateFormat = "E"
        recordCells.forEach({ recordCell in
            self.total += recordCell.amount * (recordCell.category.type == RecordType.expense.rawValue ? -1 : 1)
        })
    }
    var body: some View {
        VStack(spacing: 0) {
            HStack (alignment: .top, spacing: 0) {
                ZStack {
//                    Color.neuBackGround
//                        .cornerRadius(5)
//                        .modifier(neuShadowModifier())
//                        .padding(.horizontal, 4)
                    
                    VStack (spacing: 0)  {
                        Text("\(weekFormat.string(from: date))")
                            .style()
                        Text("\(dayFormat.string(from: date))")
                            .style()
                        
    //                    Text("¥\(abs(total))")
    //                        .planeStyle(size: 10).lineLimit(1)
                    }
                }
                .frame(width: 40, height: 40)
                ZStack {
                    VStack (spacing: 0) {
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
                    .padding(.top, 4)
                }
//                Text("\(total) 円")
//                    .planeStyle(size: 12).lineLimit(1)
//                Rectangle().frame(height: 1).foregroundColor(.nonActive)
            }
            .foregroundColor(.text)
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

            
            HStack {
                Image(icon.name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
                    .foregroundColor(Color("secondary"))
                    .padding(.trailing, 4)
                
                Text(name).style().lineLimit(1)
                Text(memo).style().lineLimit(1)
                Spacer()
                Text("¥\(amount)").style().lineLimit(1)
            }
            .foregroundColor(.text)
            .padding(.horizontal, 16)
        }
        .frame(height: 44)
    }
}
