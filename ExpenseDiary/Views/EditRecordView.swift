//
//  EditRecordView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/05.
//

import SwiftUI
import RealmSwift

struct EditRecordView: View {
    @EnvironmentObject var env: StatusObject
    @ObservedObject var viewModel = EditRecordViewModel()
    let screen = UIScreen.main.bounds
    let recordCell: RecordCell?
    let clickedDate: DateCell?

    @Environment(\.presentationMode) var presentationMode
    let formatter = DateFormatter()

    @State var showDatePicker = false
    @State var deleteTarget: RecordCell?
    @State var showingAlert: AlertItem?

    @State var type: RecordType = .expense
    @State var date = Date()
    @State var category: Category?
    
    @State var dragHeight: CGFloat = 0

    @State var amount = ""
    @State var memo = ""
    
    @State var showCalculator = false
    @State var activeMemo = false
    
    @State var success = false
    
    var iconSize: CGFloat {
        self.screen.width * 0.2
    }
    
    var showModal: Bool {
        self.showDatePicker || self.success
    }
    
    init(record: RecordCell? = nil, clickedDate: DateCell? = nil) {
        self.recordCell = record
        self.clickedDate = clickedDate
        
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = Config.MONTH_DAY_DESC
    }
    
    func addDay(_ day: Int) {
        self.date = Calendar.current.date(byAdding: .day, value: day, to: self.date)!
    }

    var body: some View {

        ScrollViewReader { scrollProxy in
            NavigationView {
                ZStack {
                    // 背景
                    Color("backGround").ignoresSafeArea(.all)
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                    
                    
                    // Success Flash
                    VStack (spacing: 20) {
                        if let category = self.category {
                            Image("\(category.icon.name)")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color(env.themeLight))
                        }
                        Text("保存しました").style(weight: .medium, tracking: 1)
                    }
                    .padding(20)
                    .frame(width: 200)
                    .background(Color("backGround"))
                    .cornerRadius(10)
                    .myShadow(radius: 5)
                    .opacity(success ? 1 : 0)
                    .zIndex(success ? 3 : 0)
                    
                    //モーダル背景
                   ZStack {
                       Color.primary.opacity(showModal ? 0.16 : 0).ignoresSafeArea(.all)
                   }
                   .onTapGesture {
                        self.showDatePicker = false
                   }
                   .zIndex(showModal ? 2 : 0)
                
                    
                    VStack(spacing: 0) {
                        // カテゴリー選択
                        ScrollView(showsIndicators: false) {
                            let columns: [GridItem] = Array(repeating: .init(.fixed(iconSize), spacing: iconSize * 0.5), count: 3)
                            LazyVGrid(columns: columns, alignment: .center, spacing: iconSize * 0.5) {
                                ForEach(Category.all(), id: \.self) { category in
                                    Button (action: {self.category = category}) {
                                        VStack(spacing: 8) {
                                            ZStack {
                                                let is_active = category == self.category
                                                
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(LinearGradient(gradient: Gradient(colors: [is_active ? Color(env.themeDark) : Color("iconBackground"), is_active ? Color(env.themeLight) : Color("iconBackground")]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                                    .frame(width: iconSize * 0.85, height: iconSize * 0.85)
                                                    .shadow(color: .black.opacity(0.1), radius: 3, x: 2, y: 2)
                                                Image(category.icon.name)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: iconSize * 0.45, height: iconSize * 0.45)
                                                    .foregroundColor(is_active ? .white :  Color("darkGray"))
                                            }
                                            
                                            Text(category.name).style(.footnote, weight: .bold).lineLimit(1).scaleEffect(1.1)
                                        }
                                        .id(category.id)
                                    }
                                }
                            }
                            .padding(.vertical, screen.width * 0.05)
                        }
                        .frame(width: screen.width * 0.8)
                        .padding(.vertical, 20)
                        
                        
                        // 金額入力
                        VStack(spacing: 0) {
                            TextField("金額", text: $amount)
                                .customTextField()
                                .disabled(true)
                                .onTapGesture {
                                    withAnimation(.linear(duration: 0.2)) {
                                        UIApplication.shared.closeKeyboard()
                                        self.showCalculator = true
                                    }
                                }
                                
                            Divider().frame(height: 1).background(showCalculator ? Color(env.themeLight) : Color("secondary"))
                        }
                        .frame(width: screen.width * 0.8)
                        .padding(.bottom, 20)
                        
                        // メモ入力
                        VStack(spacing: 0) {
                            TextField("メモ", text: $memo, onEditingChanged: { isEditing in
                                self.activeMemo = isEditing
                                self.showCalculator = false
                              }).customTextField()
                            Divider().frame(height: 1).background(activeMemo ? Color(env.themeLight) : Color("secondary"))
                        }
                        .padding(.bottom, 20)
                        .frame(width: screen.width * 0.8)

                        // 保存ボタン
                        Button(action: {
                            let result = self.viewModel.save(recordCell: recordCell, date: date, category: category, amount: amount, memo: memo)
                                
                            switch result {
                                case .success(_):
                                    withAnimation(.easeIn(duration: 0.2)) {
                                        self.success = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                        self.presentationMode.wrappedValue.dismiss()
                                    }
                                case .failure(let error):
                                    self.showingAlert = AlertItem(
                                        alert: Alert(
                                            title: Text(""),
                                            message: Text(error.message),
                                            dismissButton: .default(Text("OK"))))
                                    UIApplication.shared.closeKeyboard()
                                    withAnimation() {
                                        self.showCalculator = false
                                    }
                            }
                        }) {
                            Text("保存する").bold().style(color: .white)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .frame(width: screen.width * 0.8)
                        .padding(.top, 20)
                        .padding(.bottom, 20)

                        // 削除ボタン
                        if let recordCell = recordCell, !showCalculator, !activeMemo {
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
                                Text("削除する").style(weight: .regular, color: Color("warningDark"))
                            }
                            .padding(.bottom, 20)
                        }
                        
                        CalculatorView(show: $showCalculator, value: $amount)

                    }
                    .alert(item: $showingAlert) { item in
                        item.alert
                    }
                    .zIndex(1)

                    
                // カレンダー
                    VStack {
                        DatePicker("日付を選択", selection: $date, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .labelsHidden()

                        Button(action: { self.showDatePicker = false}) {
                            Text("完了").style(.title3, weight: .medium, color: .white)
                                .scaleEffect(0.9)
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
                    .zIndex(2)
                    

                }
                .gesture(
                    DragGesture()
                        .onEnded{ value in
                            if value.translation.width > 50 || value.translation.height > 100 {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                )
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        HStack (spacing: 0) {
                            Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(env.themeDark))
                                Text("戻る").fontWeight(.regular).foregroundColor(Color(env.themeDark))
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .principal) {
                        ZStack {
                            HStack (spacing: 0) {
                                Button(action: {
                                    withAnimation {self.showDatePicker = true}
                                }){
                                    Text(formatter.string(from: date))
                                        .bold()
                                        .style(.title3, tracking: 1)
                                        .padding(.horizontal, 16)
                                }
                            }
                        }
                    }
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        HStack {
                            Button(action:{ self.addDay(-1) }) {
                                Text("前日")
                            }
                            Button(action:{ self.addDay(1)}) {
                                Text("翌日")
                            }
                        }
                    }
                }
            }
            .accentColor(Color(env.themeDark))
            .onAppear {
                if let recordCell = self.recordCell {
                    self.category = recordCell.category
                    self.amount   = "\(recordCell.amount)"
                    self.memo     = recordCell.memo
                    self.date     = recordCell.date
                    scrollProxy.scrollTo(recordCell.category.id)
                } else if let clickedDate = self.clickedDate {
                    self.date = clickedDate.date
                }
            }
        }
    }
}


struct AlertItem: Identifiable {
    var id = UUID()
    var alert: Alert
}

