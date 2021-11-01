//
//  EditRecordView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/05.
//

import SwiftUI
import RealmSwift

struct EditRecordView: View {
    @ObservedObject var viewModel = EditRecordViewModel()
    let screen = UIScreen.main.bounds
    let recordCell: RecordCell?
    let clickedDate: Date?

    @Environment(\.presentationMode) var presentationMode
    let formatter = DateFormatter()

    @State var showDatePicker = false
    @State var deleteTarget: RecordCell?
    @State var showingAlert: AlertItem?

    @State var type: RecordType = .expense
    @State var date = Date()
    @State var category: Category?
    
    @State var dragHeight: CGFloat = 0
    
    @State var activeField: FieldType?

    @State var amount = ""
    @State var memo = ""
    
    var iconSize: CGFloat {
        self.screen.width * 0.2
    }
    
    init(record: RecordCell? = nil, clickedDate: Date? = nil) {
        self.recordCell = record
        self.clickedDate = clickedDate
        
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M-d E"
    }
    
    func addDay(_ day: Int) {
        self.date = Calendar.current.date(byAdding: .day, value: day, to: self.date)!
    }
    
    func changeType(_ type: RecordType) {
        self.type = type
        self.category = nil
    }
    
    enum FieldType {
        case amount
        case memo
    }
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ZStack {
            // 背景
                Color("backGround").ignoresSafeArea(.all)
            
                VStack(spacing: 20) {
                    // 日付
                    ZStack {
                        HStack (spacing: 0) {
                            Button(action:{ self.addDay(-1) }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.secondary)
                                    .offset(y: 2)
                                    .padding(.vertical, screen.width * 0.05)
                                    .padding(.leading, screen.width * 0.1)
                                    .padding(.trailing, screen.width * 0.05)
                            }
                            Button(action: {
                                withAnimation {self.showDatePicker = true}
                            }){
                                Text(formatter.string(from: date))
                                    .bold()
                                    .style(.title3, tracking: 1)
                                    .padding(screen.width * 0.05)
                            }
                            Button(action:{ self.addDay(1)}) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.secondary)
                                    .offset(y: 2)
                                    .padding(.vertical, screen.width * 0.05)
                                    .padding(.leading, screen.width * 0.05)
                                    .padding(.trailing, screen.width * 0.1)
                            }
                        }
                    }
                    
                    // カテゴリー選択
                        ScrollView(showsIndicators: false) {
                            let columns: [GridItem] = Array(repeating: .init(.fixed(iconSize), spacing: iconSize * 0.5), count: 3)
                            LazyVGrid(columns: columns, alignment: .center, spacing: iconSize * 0.5) {
                                ForEach(Category.all(), id: \.self) { category in
                                    VStack(spacing: 8) {
                                        ZStack {
                                            let is_active = category.id == self.category?.id
                                            
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(LinearGradient(gradient: Gradient(colors: [is_active ? Color("themeDark") : Color("backGround"), is_active ? Color("themeLight") : Color("backGround")]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                                .frame(width: iconSize * 0.85, height: iconSize * 0.85)
                                                .myShadow(radius: 3, x: 2, y: 2)
                                            Image(category.icon.name)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: iconSize * 0.5, height: iconSize * 0.5)
                                                .foregroundColor(is_active ? .white : .secondary.opacity(0.7))
                                        }
                                        .animation(.easeInOut(duration: 0.3))
                                        
                                        Text(category.name).style(.footnote, weight: .bold).lineLimit(1).scaleEffect(1.1)
                                    }
                                    .id(category.id)
                                    .onTapGesture {
                                        withAnimation() {
                                            self.category = category
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, screen.width * 0.05)
                        }
                        .padding(.bottom, screen.width * 0.05)
                    
                    
                    // 金額入力
                    VStack(spacing: 0) {
                        TextField("金額", text: $amount,
                                  onEditingChanged: { isEditing in
                                    self.activeField = isEditing ? .amount : nil
                                  }).customTextField()
                            
                        Divider().frame(height: 1).background(activeField == .amount ? Color("themeLight") : Color.secondary)
                    }
                    
                    // メモ入力
                    VStack(spacing: 0) {
                        TextField("メモ", text: $memo,
                                  onEditingChanged: { isEditing in
                                    self.activeField = isEditing ? .memo : nil
                                  }).customTextField()
                        Divider().frame(height: 1).background(activeField == .memo ? Color("themeLight") : Color.secondary)
                    }
                    .padding(.bottom, screen.width * 0.05)

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
                        Text("保存する").bold().style(color: .white)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.bottom, screen.width * 0.05)

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
                            Text("削除する").bold().style()
                        }
                    }
                }
                .padding(.vertical, 40)
                .frame(width: screen.width * 0.8)
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

                    Button(action: { self.showDatePicker = false}) {
                        Text("完了").style(.title3, color: .white)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding()
                }
                .padding(10)
                .background(Color("backGround"))
                .cornerRadius(10)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .myShadow(radius: 10, x: 0, y: 0)
                .offset(y: showDatePicker ? 0 : screen.height)
                .scaleEffect(1 - dragHeight / 1000)
                .offset(y: dragHeight)
                //.scaleEffect(showDatePicker ? 0.9 : 1)
                .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0))
                .gesture(
                    DragGesture().onChanged  { value in
                            self.dragHeight = value.translation.height > 0
                                ? value.translation.height : 0
                    }
                    .onEnded { value in
                        if self.dragHeight > 80 {
                            self.showDatePicker = false
                        }
                        self.dragHeight = .zero
                    }
                )
        }
            .onAppear {
                if let recordCell = self.recordCell {
                    self.category = recordCell.category
                    self.amount   = "\(recordCell.amount)"
                    self.memo     = recordCell.memo
                    self.date     = recordCell.date
                    scrollProxy.scrollTo(recordCell.category.id)
                } else if let clickedDate = self.clickedDate {
                    self.date = clickedDate
                    print("date")
                }
            }
        }
    }
}


struct AlertItem: Identifiable {
    var id = UUID()
    var alert: Alert
}
