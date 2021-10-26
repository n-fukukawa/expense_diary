//
//  EditRecordView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/05.
//

import SwiftUI
import RealmSwift
//
//struct EditBudgetView: View {
//    @ObservedObject var viewModel = EditBudgetViewModel()
//    let screen = UIScreen.main.bounds
//    let recordCell: RecordCell?
//
//    @Environment(\.presentationMode) var presentationMode
//    let formatter = DateFormatter()
//
//    @State var showDatePicker = false
//    @State var deleteTarget: RecordCell?
//    @State var showingAlert: AlertItem?
//
//    @State var type: RecordType = .expense
//    @State var year: Int
//    @State var category: Category?
//
//    
//
//    @State var amount = ""
//    @State var memo = ""
//    
//    var iconSize: CGFloat {
//        self.screen.width * 0.2
//    }
//    
//    init(record: RecordCell? = nil) {
//        self.recordCell = record
//        
//        formatter.locale = Locale(identifier: "ja_JP")
//        formatter.dateFormat = "M-d E"
//    }
//    
//    func addDay(_ day: Int) {
//        self.date = Calendar.current.date(byAdding: .day, value: day, to: self.date)!
//    }
//    
//    func changeType(_ type: RecordType) {
//        self.type = type
//        self.category = nil
//    }
//    
//    var body: some View {
//        ScrollViewReader { scrollProxy in
//            ZStack {
//            // 背景
//            Color.backGround.ignoresSafeArea(.all)
//            
//                VStack(spacing: 20) {
//                    // タブ
////                    HStack(spacing: 0) {
////                        ForEach(RecordType.all(), id: \.self) { recordType in
////                            Button(action: {
////                                self.changeType(recordType)
////                            }){
////                                let is_active = self.type == recordType
////                                VStack(spacing: 4) {
////                                    Text(recordType.name).planeStyle(size: 16)
////                                    RoundedRectangle(cornerRadius: 10)
////                                    .frame(width: 20, height: 2)
////                                    .opacity(is_active ? 1 : 0)
////                                    .foregroundColor(.sub)
////                                }
////                                .frame(maxWidth: .infinity)
////                            }
////                        }
////                    }
//                    
//                    // 日付
//                    ZStack {
//                        HStack (spacing: 0) {
//                            Button(action:{ self.addDay(-1) }) {
//                                Image(systemName: "chevron.left")
//                                    .font(.system(size: 14, weight: .bold))
//                                    .foregroundColor(.text)
//                                    .offset(y: 2)
//                                    .padding(.vertical, screen.width * 0.05)
//                                    .padding(.leading, screen.width * 0.1)
//                                    .padding(.trailing, screen.width * 0.05)
//                            }
//                            Button(action: {
//                                withAnimation {self.showDatePicker = true}
//                            }){
//                                Text(formatter.string(from: date))
//                                    .bold()
//                                    .planeStyle(size: 22)
//                                    .padding(screen.width * 0.05)
//                            }
//                            Button(action:{ self.addDay(1)}) {
//                                Image(systemName: "chevron.right")
//                                    .font(.system(size: 14, weight: .bold))
//                                    .foregroundColor(.text)
//                                    .offset(y: 2)
//                                    .padding(.vertical, screen.width * 0.05)
//                                    .padding(.leading, screen.width * 0.05)
//                                    .padding(.trailing, screen.width * 0.1)
//                            }
//                        }
//                    }
//                    
//                    // カテゴリー選択
//                        ScrollView(showsIndicators: false) {
//                            let columns: [GridItem] = Array(repeating: .init(.fixed(iconSize), spacing: iconSize * 0.5), count: 3)
//                            LazyVGrid(columns: columns, alignment: .center, spacing: iconSize * 0.5) {
//                                ForEach(Category.all().sorted(by: sortProperties), id: \.self) { category in
//                                    VStack(spacing: 4) {
//                                        ZStack {
//                                            let is_active = category.id == self.category?.id
//                                            
//                                            RoundedRectangle(cornerRadius: 0)
//                                                .foregroundColor(is_active ? .main : .backGround)
//                                                .frame(width: iconSize * 0.85, height: iconSize * 0.85)
//                                                .shadow(color: .dropShadow.opacity(0.1), radius: 5, x: 2, y: 2)
//                                            Image(category.icon.name)
//                                                .resizable()
//                                                .aspectRatio(contentMode: .fit)
//                                                .frame(width: iconSize * 0.45, height: iconSize * 0.45)
//                                                .foregroundColor(is_active ? .white : .nonActive)
//                                        }
//                                        
//                                        Text(category.name).planeStyle(size: 14).lineLimit(1)
//                                    }
//                                    .id(category.id)
//                                    .onTapGesture {
//                                        self.category = category
//                                    }
//                                }
//                            }
//                            .padding(.vertical, screen.width * 0.05)
//                        }
//                        .padding(.bottom, screen.width * 0.05)
//                    
//                    
//                    // 金額入力
//                    VStack(spacing: 0) {
//                        TextField("金額", text: $amount).customTextField(size: 18)
//                            
//                        Divider().frame(height: 1).background(Color.nonActive)
//                    }
//                    .padding(.horizontal, screen.width * 0.08)
//                    
//                    // メモ入力
//                    VStack(spacing: 0) {
//                        TextField("メモ", text: $memo).customTextField(size: 18)
//                        Divider().frame(height: 1).background(Color.nonActive)
//                    }
//                    .padding(.horizontal, screen.width * 0.08)
//                    .padding(.bottom, screen.width * 0.05)
//
//                    // 保存ボタン
//                    Button(action: {
//                        let result = self.viewModel.save(recordCell: recordCell, date: date, category: category, amount: amount, memo: memo)
//                            
//                        switch result {
//                            case .success(_):
//                                self.presentationMode.wrappedValue.dismiss()
//                            case .failure(let error):
//                                self.showingAlert = AlertItem(
//                                    alert: Alert(
//                                        title: Text(""),
//                                        message: Text(error.message),
//                                        dismissButton: .default(Text("OK"))))
//                        }
//                    }) {
//                        Text("保存する").bold().outlineStyle(size: 18)
//                    }
//                    .buttonStyle(PrimaryButtonStyle())
//                    .padding(.horizontal, screen.width * 0.08)
//                    .padding(.bottom, screen.width * 0.05)
//
//                    // 削除ボタン
//                    if let recordCell = recordCell {
//                        Button(action: {
//                            self.showingAlert = AlertItem(
//                                alert: Alert(
//                                     title: Text(""),
//                                     message: Text("削除しますか?"),
//                                     primaryButton: .cancel(Text("キャンセル")),
//                                     secondaryButton: .destructive(Text("削除"),
//                                     action: {
//                                        self.viewModel.delete(recordCell: self.deleteTarget)
//                                        self.presentationMode.wrappedValue.dismiss()
//                                   })))
//                            self.deleteTarget = recordCell
//                        }) {
//                            Text("削除する").bold().planeStyle(size: 16)
//                        }
//                    }
//                }
//                .padding(.vertical, 40)
//                .frame(width: screen.width * 0.9)
//                .alert(item: $showingAlert) { item in
//                    item.alert
//                }
//            
//            //モーダル背景
//               ZStack {
//                   Color.black.opacity(self.showDatePicker ? 0.16 : 0).ignoresSafeArea(.all)
//               }
//               .onTapGesture {
//                    self.showDatePicker = false
//               }
//                
//            // カレンダー
//                VStack {
//                    DatePicker("日付を選択", selection: $date, displayedComponents: .date)
//                        .datePickerStyle(GraphicalDatePickerStyle())
//                        .labelsHidden()
//
//                    Button(action: { self.showDatePicker = false}) {
//                        Text("OK")
//                            .planeStyle(size: 20)
//                            .padding(.bottom, 20)
//                    }
//                }
//                .padding(10)
//                .background(Color.backGround)
//                .cornerRadius(10)
//                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
//                .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)).opacity(0.2), radius: 20, x: 0, y: 20)
//                .offset(y: showDatePicker ? 0 : screen.height)
//                .scaleEffect(1 - dragHeight / 1000)
//                .offset(y: dragHeight)
//                //.scaleEffect(showDatePicker ? 0.9 : 1)
//                .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0))
//                .gesture(
//                    DragGesture().onChanged  { value in
//                            self.dragHeight = value.translation.height > 0
//                                ? value.translation.height : 0
//                    }
//                    .onEnded { value in
//                        if self.dragHeight > 80 {
//                            self.showDatePicker = false
//                        }
//                        self.dragHeight = .zero
//                    }
//                )
//        }
//            .onAppear {
//                if let recordCell = self.recordCell {
//                    self.category = recordCell.category
//                    self.amount   = "\(recordCell.amount)"
//                    self.memo     = recordCell.memo
//                    self.date     = recordCell.date
//                    scrollProxy.scrollTo(recordCell.category.id)
//                }
//            }
//        }
//    }
//}
//
//
//class EditRecordViewModel: ObservableObject {
//    func save(recordCell: RecordCell?, date: Date, category: Category?, amount: String, memo: String)
//        -> Result<Record, EditRecordError>
//    {
//        // バリデーション
//        guard let category = category else {
//            return .failure(.categoryIsEmpty)
//        }
//        if amount.isEmpty {
//            return .failure(.amountIsEmpty)
//        }
//        guard let amount = Int(amount) else {
//            return .failure(.amountNotNumeric)
//        }
//        if amount < 0  {
//            return .failure(.amountNotNumeric)
//        }
//        if memo.count > Config.RECORD_MEMO_MAX  {
//            return .failure(.memoTooLong)
//        }
//        
//        // 更新
//        if let recordCell = recordCell {
//            if let record = Record.getById(recordCell.id) {
//                let updatedRecord = Record.update(record: record, date: date, category: category, amount: amount, memo: memo)
//                return .success(updatedRecord)
//            }
//            
//            return .failure(.recordNotFound)
//        }
//        
//        // 新規作成
//        let record = Record.create(date: date, category: category, amount: amount, memo: memo)
//
//        return .success(record)
//    }
//    
//    func delete(recordCell: RecordCell?) {
//        if let recordCell = recordCell {
//            if let record = Record.getById(recordCell.id) {
//                Record.delete(record)
//            }
//        }
//    }
//}
//
//enum EditRecordError : Error {
//    case amountIsEmpty
//    case amountNotNumeric
//    case categoryIsEmpty
//    case memoTooLong
//    case recordNotFound
//    
//    var message: String {
//        switch self {
//        case .amountIsEmpty     : return "金額を入力してください"
//        case .amountNotNumeric  : return "金額には正の整数を入力してください"
//        case .categoryIsEmpty   : return "カテゴリーを選択してください"
//        case .memoTooLong       : return "メモは\(Config.RECORD_MEMO_MAX)文字以内で入力してください"
//        case .recordNotFound    : return "記録がみつかりませんでした"
//        }
//    }
//}
//
//struct AlertItem: Identifiable {
//    var id = UUID()
//    var alert: Alert
//}
