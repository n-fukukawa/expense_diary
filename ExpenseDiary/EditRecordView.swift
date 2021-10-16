//
//  EditRecordView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/05.
//

import SwiftUI

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

struct EditRecordView: View {
    @ObservedObject var viewModel = EditRecordViewModel()
    // @Binding var isActive: Bool
    let recordCell: RecordCell?

    @Environment(\.presentationMode) var presentationMode
    let screen = UIScreen.main.bounds
    let formatter = DateFormatter()
    
    @State var showAlert = false
    @State var showDatePicker = false
    @State var showError = false
    @State var showConfirm = false
    @State var deleteTarget: RecordCell?
    
    var showModal: Bool {
        self.showDatePicker || self.showError || self.showConfirm
    }
    
    @State var error: EditRecordError?

    @State var type: RecordType = .expense
    @State var date = Date()
    @State var category: Category?
    @State var categories = Category.getByType(.expense)
    @State var amount = ""
    @State var memo = ""
    
    init(record: RecordCell? = nil) {
        // self._isActive = isActive
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
            Color.backGround.ignoresSafeArea(.all)
            
                VStack(spacing: 0) {
                    // タブ
                    HStack(spacing: 0) {
                        ForEach(RecordType.all(), id: \.self) { recordType in
                            Button(action: {
                                self.changeType(recordType)
                            }){
                                let is_active = self.type == recordType
                                VStack(spacing: 8) {
                                    if is_active {
                                        Text(recordType.name).planeStyle(size: 16)
                                        Rectangle().frame(height: 3).offset(x: 0, y: -1)
                                    } else {
                                        Text(recordType.name).planeStyle(size: 16)
                                        Rectangle().frame(height: 1)
                                    }
                                }.foregroundColor(.text)
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
                                    self.showDatePicker = true
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
                        
                    Divider()
                    
                    // カテゴリー選択
                    ScrollView(showsIndicators: false) {
                        let columns: [GridItem] = Array(repeating: .init(.fixed(90), spacing: 20), count: 3)
                        LazyVGrid(columns: columns, alignment: .center, spacing: 30) {
                            ForEach(categories, id: \.self) { category in
                                VStack(spacing: 4) {
                                    ZStack {
                                        let is_active = category.id == self.category?.id
                                        
                                        Circle().foregroundColor(is_active ? .accent : .white)
                                            .frame(width: 52, height: 52)
                                            .shadow(color: .nonActive.opacity(is_active ? 0.4 : 1), radius: is_active ? 6 : 1)
                                        Image(category.icon.name)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 26, height: 26)
                                            .foregroundColor(is_active ? .white : .nonActive)
                                    }
                                    Text(category.name).planeStyle(size: 14)
                                        .foregroundColor(.text)
                                }
                                .alert(isPresented: $showAlert){
                                    Alert(title: Text("ロングタップ"))
                                }
                                .onTapGesture {
                                    self.category = category
                                }
                                .onLongPressGesture(minimumDuration: 0.7) {
                                    self.category = category
                                    self.showAlert = true
                                }

                            }
                        }
                        .padding(.vertical, 20)
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
                                self.error = error
                                self.showError = true
                        }
                    }) {
                        Text("保存する").bold().outlineStyle(size: 20)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)

                    // 削除ボタン
                    if let _recordCell = recordCell {
                        Button(action: {
                            self.showConfirm = true
                            self.deleteTarget = _recordCell
                        }) {
                            Text("削除する").bold().planeStyle(size: 16)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 30)
                .padding(16)
                .background(Color.backGround)
//                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
//                .shadow(color: Color(.black).opacity(showDatePicker ? 0.2 : 0), radius: 20, x: 0, y: 20)
                .scaleEffect(showModal ? 1 : 1)
                .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0))
            
            // モーダル背景
            ZStack {
                Color.black.opacity(self.showModal ? 0.3 : 0).ignoresSafeArea(.all)
                    .animation(Animation.easeIn)
            }
            .onTapGesture {
                self.showDatePicker = false
                self.showError = false
                self.showConfirm = false
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
                .background(Color.backGround)
                .cornerRadius(10)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)).opacity(0.2), radius: 20, x: 0, y: 20)
                .offset(y: showDatePicker ? 0 : screen.height)
                .scaleEffect(showDatePicker ? 0.9 : 1)
                .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0))
            
            // エラー
            if let error = self.error {
                VStack(spacing: 0) {
                    Text(error.message).planeStyle(size: 18)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 40)
                    Divider()
                    Button(action: { self.showError = false }) {
                        Text("OK").planeStyle(size: 18)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(width: screen.width * 0.9)
                .modifier(ModalCardModifier(active: showError))
            }
            
            // 削除確認
            VStack(spacing: 0) {
                Text("削除しますか？").planeStyle(size: 18)
                    .padding(.vertical, 40)
                Divider()
                HStack(spacing: 0) {
                    Button(action: { self.showConfirm = false }) {
                        Text("キャンセル").bold().outlineStyle(size: 20)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                    }
                    .background(Color.nonActive)
                    Button(action: {
                        self.viewModel.delete(recordCell: self.deleteTarget)
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("削除する").bold().outlineStyle(size: 20)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                    }
                    .background(Color.main)
                }
            }
            .frame(width: screen.width * 0.9)
            .modifier(ModalCardModifier(active: showConfirm))

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

struct EditRecordView_Previews: PreviewProvider {
    static var previews: some View {
//        let devices = ["iPhone 12", "iPhone 8 Plus", "iPad Air(4th generation)"]
        let devices = ["iPhone 12"]
        ForEach(devices, id: \.self) { device in
            EditRecordView().environmentObject(StatusObject())
                       .previewDevice(.init(rawValue: device))
                        .environment(\.locale, Locale(identifier: "ja_JP"))
        }
    }
}
