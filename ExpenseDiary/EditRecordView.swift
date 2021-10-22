//
//  EditRecordView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/05.
//

import SwiftUI


struct EditRecordView: View {
    @ObservedObject var viewModel = EditRecordViewModel()
    let recordCell: RecordCell?

    @Environment(\.presentationMode) var presentationMode
    let screen = UIScreen.main.bounds
    let formatter = DateFormatter()

    @State var showDatePicker = false
    @State var deleteTarget: RecordCell?
    @State var showingAlert: AlertItem?

    @State var type: RecordType = .expense
    @State var date = Date()
    @State var category: Category?
    @State var categories = Category.getByType(.expense)
    @State var amount = ""
    @State var memo = ""
    
    init(record: RecordCell? = nil) {
        self.recordCell = record
        
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d(E)"
    }
    
    func addDay(_ day: Int) {
        self.date = Calendar.current.date(byAdding: .day, value: day, to: self.date)!
    }
    
    func changeType(_ type: RecordType) {
        self.type = type
        self.category = nil
        self.categories = Category.getByType(self.type)
    }
    
    var body: some View {
    
        ZStack {
            // 背景
            Color.neuBackGround.ignoresSafeArea(.all)
            
                VStack(spacing: 0) {

                    // タブ
                    HStack(spacing: 0) {
                        ForEach(RecordType.all(), id: \.self) { recordType in
                            Button(action: {
                                self.changeType(recordType)
                            }){
                                let is_active = self.type == recordType
                                VStack(spacing: 4) {
                                    Text(recordType.name).planeStyle(size: 16)
                                    RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 20, height: 2)
                                    .opacity(is_active ? 1 : 0)
                                    .foregroundColor(.sub)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                    
                    // 日付
                    ZStack {
                        HStack (spacing: 24) {
                            Button(action:{ self.addDay(-1) }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.text)
                                    .offset(y: 2)
                            }
                            Text(formatter.string(from: date))
                                .bold()
                                .planeStyle(size: 22)
                                .onTapGesture {
                                    withAnimation {self.showDatePicker = true}
                            }
                            Button(action:{ self.addDay(1)}) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.text)
                                    .offset(x: -6, y: 2)
                            }
                        }
                        .padding(.bottom, 24)
                    }
                    

                        
                    // カテゴリー選択
                    ScrollView(.horizontal, showsIndicators: false) {
                        let rows: [GridItem] = Array(repeating: .init(.fixed(100), spacing: 30), count: 2)
                        LazyHGrid(rows: rows, alignment: .center, spacing: 40) {
                            ForEach(categories, id: \.self) { category in
                                VStack(spacing: 4) {
                                    ZStack {
                                        let is_active = category.id == self.category?.id
                                        
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(is_active ? .main : .neuBackGround)
                                            .frame(width: 72, height: 72)
                                            .modifier(neuShadowModifier())
                                        Image(category.icon.name)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 36, height: 36)
                                            .foregroundColor(is_active ? .white : .nonActive)
                                    }
                                    Text(category.name).planeStyle(size: 14).lineLimit(1)
                                        .foregroundColor(.text)
                                }
                                .onTapGesture {
                                    self.category = category
                                }
                            }
                        }
                        .padding(.vertical, 30)
                        .padding(.horizontal, 20)
                    }
                    
                    Divider()
                        .padding(.bottom, 40)
                    
                    // 金額入力
                    VStack(spacing: 0) {
                        TextField("金額", text: $amount)
                            .padding(10)
                            .foregroundColor(.text)
                            .background(Color.white)
                        Divider().frame(height: 1).background(Color.nonActive)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    
                    // メモ入力
                    VStack(spacing: 0) {
                        TextField("メモ", text: $memo)
                            .padding(10)
                            .foregroundColor(.text)
                            .background(Color.white)
                        Divider().frame(height: 1).background(Color.nonActive)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                    // 保存ボタン
                    Button(action: {
                        let result = self.viewModel.save(recordCell: recordCell, date: date, category: category, amount: amount, memo: memo)
                            
                        switch result {
                            case .success(_):
                                self.presentationMode.wrappedValue.dismiss()
                            case .failure(let error):
                                self.showingAlert = AlertItem(
                                    alert: Alert(
                                        title: Text(""),
                                        message: Text(error.message),
                                        dismissButton: .default(Text("OK"))))
                        }
                    }) {
                        Text("保存する").bold().outlineStyle(size: 18)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)

                    // 削除ボタン
                    if let recordCell = recordCell {
                        Button(action: {
                            self.showingAlert = AlertItem(
                                alert: Alert(
                                     title: Text(""),
                                     message: Text("削除しますか?"),
                                     primaryButton: .cancel(Text("キャンセル")),
                                     secondaryButton: .destructive(Text("削除"),
                                     action: {
                                        self.viewModel.delete(recordCell: self.deleteTarget)
                                        self.presentationMode.wrappedValue.dismiss()
                                   })))
                            self.deleteTarget = recordCell
                        }) {
                            Text("削除する").bold().planeStyle(size: 16)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 30)
                .padding(16)
                .alert(item: $showingAlert) { item in
                    item.alert
                }
            
            //モーダル背景
               ZStack {
                   Color.black.opacity(self.showDatePicker ? 0.16 : 0).ignoresSafeArea(.all)
               }
               .onTapGesture {
                    self.showDatePicker = false
               }
                
            // カレンダー
                VStack {
                    DatePicker("日付を選択", selection: $date, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .labelsHidden()

                    Text("OK")
                        .planeStyle(size: 18)
                        .padding(.bottom, 20)
                        .onTapGesture {
                            self.showDatePicker = false
                        }
                }
                .padding(10)
                .background(Color.neuBackGround)
                .cornerRadius(10)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)).opacity(0.2), radius: 20, x: 0, y: 20)
                .offset(y: showDatePicker ? 0 : screen.height)
                .scaleEffect(showDatePicker ? 0.9 : 1)
                .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0))
        }
        .onAppear {
            if let _recordCell = self.recordCell {
                self.category = _recordCell.category
                self.amount   = "\(_recordCell.amount)"
                self.memo     = _recordCell.memo
                self.date     = _recordCell.date
            }
        }
    }
}


class EditRecordViewModel: ObservableObject {
    func save(recordCell: RecordCell?, date: Date, category: Category?, amount: String, memo: String)
        -> Result<Record, EditRecordError>
    {
        // バリデーション
        guard let category = category else {
            return .failure(.categoryIsEmpty)
        }
        if amount.isEmpty {
            return .failure(.amountIsEmpty)
        }
        guard let amount = Int(amount) else {
            return .failure(.amountNotNumeric)
        }
        if amount < 0  {
            return .failure(.amountNotNumeric)
        }
        if memo.count > Config.RECORD_MEMO_MAX  {
            return .failure(.memoTooLong)
        }
        
        // 更新
        if let recordCell = recordCell {
            if let record = Record.getById(recordCell.id) {
                let updatedRecord = Record.update(record: record, date: date, category: category, amount: amount, memo: memo)
                return .success(updatedRecord)
            }
            
            return .failure(.recordNotFound)
        }
        
        // 新規作成
        let record = Record.create(date: date, category: category, amount: amount, memo: memo)

        return .success(record)
    }
    
    func delete(recordCell: RecordCell?) {
        if let recordCell = recordCell {
            if let record = Record.getById(recordCell.id) {
                Record.delete(record)
            }
        }
    }
}

enum EditRecordError : Error {
    case amountIsEmpty
    case amountNotNumeric
    case categoryIsEmpty
    case memoTooLong
    case recordNotFound
    
    var message: String {
        switch self {
        case .amountIsEmpty     : return "金額を入力してください"
        case .amountNotNumeric  : return "金額には正の整数を入力してください"
        case .categoryIsEmpty   : return "カテゴリーを選択してください"
        case .memoTooLong       : return "メモは\(Config.RECORD_MEMO_MAX)文字以内で入力してください"
        case .recordNotFound    : return "記録がみつかりませんでした"
        }
    }
}

struct AlertItem: Identifiable {
    var id = UUID()
    var alert: Alert
}
