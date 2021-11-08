//
//  PresetViews.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/10.
//

import SwiftUI
import RealmSwift


struct PresetMenuView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel = PresetViewModel()
    @Binding var showSettingMenu: Bool
    let screen = UIScreen.main.bounds
    
    @State var type = RecordType.expense
    @State var isShowing = false
    
    @State var selectedPresetCell: PresetCell?
    
    @State var showingAlert: AlertItem?
    @State var deleteTarget: PresetCell?

    
    private func close() {
        self.presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        ZStack {
            Color("backGround")
            VStack {
                HStack {
                    Picker(selection: $type, label: Text("支出収入区分")) {
                        ForEach(RecordType.all(), id: \.self) { recordType in
                            Text("固定\(recordType.name)").style()
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 16)
                List {
                    let presetCells = viewModel.getPresetCells(type: type)
                    ForEach(presetCells, id: \.key) { day, cells in
                        Section(header: Text("毎月\(day)日").style(.caption, color: .primary)) {
                            ForEach(cells, id: \.id) { presetCell in
                                HStack (spacing: 12) {
                                    Text(presetCell.category.name).style(.title3)
                                    Text(presetCell.memo).style(.caption).scaleEffect(1.2)
                                    Spacer()
                                    Text("\(presetCell.amount) 円").style()
                                }
                                .padding(.vertical, 6)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    self.selectedPresetCell = presetCell
                                }
                            }
                        }
                    }
                }
                .sheet(item: $selectedPresetCell) { presetCell in
                    EditPresetView(presetCell: presetCell, type: RecordType.of(presetCell.category.type))
                }
            }
            .padding(.horizontal, 16)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: { self.isShowing = true }) {
                    Text("作成").style()
                }
            }
        }
        .sheet(isPresented: $isShowing) {
            EditPresetView(presetCell: nil, type: type)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: { self.close() } )
            {
                HStack {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                    Text("戻る").fontWeight(.regular)
                }
            })
        .onAppear() {
            self.showSettingMenu = false
        }
    }
}

struct EditPresetView: View {
    @ObservedObject var viewModel = PresetViewModel()
    let presetCell: PresetCell?
    let type: RecordType
    
    let screen = UIScreen.main.bounds

    @Environment(\.presentationMode) var presentationMode
    let formatter = DateFormatter()

    @State var deleteTarget: PresetCell?
    @State var showingAlert: AlertItem?

    @State var day: Int = 15
    @State var category: CategoryCell?

    @State var amount = ""
    @State var memo = ""
    
    @State var showCalculator = false
    @State var activeMemo = false
    
    var iconSize: CGFloat {
        self.screen.width * 0.2
    }
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ZStack {
            // 背景
                Color("backGround").ignoresSafeArea(.all)
            
                VStack(spacing: 20) {
                    Spacer(minLength: 30)
                    
                    Picker ("日を選択", selection: $day) {
                        ForEach(1...28, id: \.self) { day in
                            Text("毎月\(day)日").style(color: .primary)
                        }
                    }
                    .frame(width: 180, height: showCalculator ? 0 : 90)
                    .clipped()
                    
                    // カテゴリー選択
                    ScrollView(showsIndicators: false) {
                        let columns: [GridItem] = Array(repeating: .init(.fixed(iconSize), spacing: iconSize * 0.5), count: 3)
                        LazyVGrid(columns: columns, alignment: .center, spacing: iconSize * 0.5) {
                            ForEach(viewModel.getCategoryCells(type: type), id: \.self) { category in
                                Button (action: {self.category = category}) {
                                    VStack(spacing: 8) {
                                        ZStack {
                                            let is_active = category == self.category

                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(LinearGradient(gradient: Gradient(colors: [is_active ? Color("themeDark") : Color("backGround"), is_active ? Color("themeLight") : .white]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                                .frame(width: iconSize * 0.85, height: iconSize * 0.85)
                                                .shadow(color: .primary.opacity(0.1), radius: 2, x: 2, y: 2)
                                            Image(category.icon.name)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: iconSize * 0.5, height: iconSize * 0.5)
                                                .foregroundColor(is_active ? .white : .secondary.opacity(0.7))
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
                    .padding(.bottom, screen.width * 0.05)
                    
                    
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
                            
                        Divider().frame(height: 1).background(showCalculator ? Color("themeLight") : Color.secondary)
                    }
                    .frame(width: screen.width * 0.8)
                    
                    // メモ入力
                    VStack(spacing: 0) {
                        TextField("メモ", text: $memo, onEditingChanged: { isEditing in
                            self.activeMemo = isEditing
                            self.showCalculator = false
                          }).customTextField()
                        Divider().frame(height: 1).background(activeMemo ? Color("themeLight") : Color.secondary)
                    }
                    .padding(.bottom, screen.width * 0.05)
                    .frame(width: screen.width * 0.8)

                    // 保存ボタン
                    Button(action: {
                        let result = self.viewModel.save(presetCell: presetCell, categoryCell: category, day: day, amount: amount, memo: memo)
                            
                        switch result {
                            case .success(_):
                                Batch.presetBatch()
                                self.presentationMode.wrappedValue.dismiss()
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
                    .padding(.bottom, screen.width * 0.05)

                    // 削除ボタン
                    if let presetCell = presetCell, !showCalculator, !activeMemo {
                        Button(action: {
                            self.showingAlert = AlertItem(
                                alert: Alert(
                                     title: Text(""),
                                     message: Text("削除しますか?"),
                                     primaryButton: .cancel(Text("キャンセル")),
                                     secondaryButton: .destructive(Text("削除"),
                                     action: {
                                        self.viewModel.delete(presetCell: self.deleteTarget)
                                        self.presentationMode.wrappedValue.dismiss()
                                   })))
                            self.deleteTarget = presetCell
                        }) {
                            Text("削除する").bold().style()
                        }
                    }
                    
                    
                    CalculatorView(show: $showCalculator, value: $amount)

                }
                .alert(item: $showingAlert) { item in
                    item.alert
                }
                .ignoresSafeArea(.keyboard, edges: .top)
        }
            .onAppear {
                if let presetCell = self.presetCell {
                    self.category = CategoryCell.generateFromCategory(category: presetCell.category)
                    self.amount   = "\(presetCell.amount)"
                    self.memo     = presetCell.memo
                    self.day      = presetCell.day
                    scrollProxy.scrollTo(presetCell.category.id)
                }
            }
        }
    }
}
