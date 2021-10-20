//
//  PresetViews.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/10.
//

import SwiftUI
import RealmSwift

class PresetViewModel: ObservableObject {
    @Published var presetCells: [PresetCell] = []
    
    private var presets: Results<Preset>
    private var notificationTokens: [NotificationToken] = []
    
    init() {
        self.presets = Preset.all()
        self.setPresetCells(presets: self.presets)
        
        notificationTokens.append(presets.observe { change in
            switch change {
                case let .initial(results):
                    self.setPresetCells(presets: results)
                    print("changed")
                case let .update(results, _, _, _):
                    self.setPresetCells(presets: results)
                    print("update")
                case let .error(error):
                    print(error.localizedDescription)
            }
        })
    }
    
    private func setPresetCells(presets: Results<Preset>) {
        self.presetCells = presets.map {
            PresetCell(id: $0.id, category: $0.category, amount: $0.amount, memo: $0.memo, order: $0.order, created_at: $0.created_at, updated_at: $0.updated_at)
        }
    }
    
    func getPresetCells(type: RecordType) -> [PresetCell] {
        self.presetCells.filter{$0.category.type == type.rawValue}
    }
    
    func save(presetCell: PresetCell?, category: Category?, amount: String, memo: String)
        -> Result<Preset, EditPresetError>
    {
        var _amount = amount
        
        // バリデーション
        guard let category = category else {
            return .failure(.categoryIsEmpty)
        }
        if _amount.isEmpty && memo.isEmpty {
            return .failure(.bothEmpty)
        }
        if _amount.isEmpty {
            _amount = "0"
        }
        if memo.count > Config.CATEGORY_NAME_MAX  {
            return .failure(.memoTooLong)
        }
        
        guard let amount = Int(_amount) else {
            return .failure(.amountNotNumeric)
        }
        if amount < 0  {
            return .failure(.amountNotNumeric)
        }
        
        // 更新
        if let presetCell = presetCell {
            if let preset = Preset.getById(presetCell.id) {
                let updatePreset = Preset.update(preset: preset, category: category, amount: amount, memo: memo)
                return .success(updatePreset)
            }
            
            return .failure(.presetNotFound)
        }
        
        // 新規作成
        let preset = Preset.create(category: category, amount: amount, memo: memo)

        return .success(preset)
    }
    
    func delete(presetCell: PresetCell?) {
        if let presetCell = presetCell {
            if let preset = Preset.getById(presetCell.id) {
                Preset.delete(preset)
            }
        }
    }
    
    func move(type: RecordType, _ from: IndexSet, _ to: Int) {
        let presets = self.getPresetCells(type: type)
        guard let source = from.first else {
            return
        }
        
        if source < to {
            print(source, to)
            for i in (source + 1)...(to - 1) {
                if let preset = Preset.getById(presets[i].id) {
                    Preset.updateOrder(preset: preset, order: i)
                }
            }
            if let preset = Preset.getById(presets[source].id) {
                Preset.updateOrder(preset: preset, order: to)
            }
        } else if source > to {
            print(source, to)
            var count = 0
            for i in (to...(source - 1)).reversed() {
                if let preset = Preset.getById(presets[i].id) {
                    Preset.updateOrder(preset: preset, order: source + 1 - count)
                }
                count += 1
            }
            if let preset = Preset.getById(presets[source].id) {
                Preset.updateOrder(preset: preset, order: to + 1)
            }
        }
    }
}

enum EditPresetError : Error {
    case categoryIsEmpty
    case bothEmpty
    case amountNotNumeric
    case memoTooLong
    case presetNotFound
    
    var message: String {
        switch self {
        case .categoryIsEmpty  : return "カテゴリーを選択してください"
        case .bothEmpty        : return "金額またはメモのどちらかは入力してください"
        case .amountNotNumeric : return "金額には正の整数を入力してください"
        case .memoTooLong      : return "メモは\(Config.RECORD_MEMO_MAX)文字以内で入力してください"
        case .presetNotFound   : return "プリセットがみつかりませんでした"
        }
    }
}

struct PresetMenuView: View {
    @ObservedObject var viewModel = PresetViewModel()
    let screen = UIScreen.main.bounds
    
    @State var type = RecordType.expense
    @State var isShowing = false
    
    @State var selectedPresetCell: PresetCell?
    
    @State var showingAlert: AlertItem?
    @State var deleteTarget: PresetCell?
    
    private func move(_ from: IndexSet, _ to: Int) {
        self.viewModel.move(type: self.type, from, to)
    }
    
    var body: some View {
        ZStack {
            ZStack {
                Color.backGround
                VStack {
                    HStack {
                        Picker(selection: $type, label: Text("支出収入区分")) {
                            ForEach(RecordType.all(), id: \.self) { recordType in
                                Text(recordType.name).planeStyle(size: 16)
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
                        ForEach(presetCells, id: \.id) { presetCell in
                            HStack {
                                Text(presetCell.category.name).planeStyle(size: 16)
                                Text(presetCell.memo).planeStyle(size: 14)
                                Spacer()
                                Text("\(presetCell.amount) 円").planeStyle(size: 16)
                            }
                            .padding(6)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.selectedPresetCell = presetCell
                            }
                        }
                        .onMove(perform: move)
                        .onDelete(perform: { indexSet in
                            guard let index = indexSet.first else {
                                return
                            }
                            self.deleteTarget = presetCells[index]
                            self.showingAlert = AlertItem(alert: Alert(
                                  title: Text(""),
                                  message:Text("削除しますか？"),
                                  primaryButton: .cancel(Text("キャンセル")),
                                  secondaryButton: .destructive(Text("削除"),
                                  action: {
                                       self.viewModel.delete(presetCell: self.deleteTarget)
                                  })))
                        })
                    }
                    .sheet(item: $selectedPresetCell) { presetCell in
                        EditPresetView(presetCell: presetCell)
                    }
                    .alert(item: $showingAlert) { item in
                        item.alert
                    }
                }
                .padding(.horizontal, 16)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { self.isShowing = true }) {
                        Text("作成").planeStyle(size: 14)
                    }

                    MyEditButton().foregroundColor(.text)
                        .padding(.trailing, 20)
                }
            }
            .sheet(isPresented: $isShowing) {
                EditPresetView(presetCell: nil)
            }
        }
    }
}

struct EditPresetView: View {
    let presetCell: PresetCell?
    @ObservedObject var viewModel = PresetViewModel()
    let screen = UIScreen.main.bounds
    
    @Environment(\.presentationMode) var presentationMode

    
    @State var type: RecordType = .expense
    @State var category: Category?
    @State var categories = Category.getByType(.expense)
    @State var amount = ""
    @State var memo = ""
    
    @State var showingAlert: AlertItem?

    var body: some View {
        ZStack {
            Color.backGround.ignoresSafeArea(.all)
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(RecordType.all(), id: \.self) { recordType in
                        Button(action: {
                            self.type = recordType
                            self.category = nil
                            self.categories = Category.getByType(self.type)
                        }){
                            let is_active = self.type == recordType
                            VStack(spacing: 8) {
                                if is_active {
                                    Text(recordType.name).planeStyle(size: 18)
                                    Rectangle().frame(height: 3).offset(x: 0, y: -1)
                                } else {
                                    Text(recordType.name).planeStyle(size: 18)
                                    Rectangle().frame(height: 1)
                                }
                            }
                            .foregroundColor(.text)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 36)
                
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
                            .onTapGesture {
                                self.category = category
                            }
                        }
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
                
                Divider()
                    .padding(.bottom, 40)
                
                VStack(spacing: 0) {
                    TextField("金額", text: $amount)
                        .padding(10)
                        .foregroundColor(.text)
                        .background(Color.white)
                    Divider().frame(height: 1).background(Color.nonActive)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                
                VStack(spacing: 0) {
                    TextField("メモ", text: $memo)
                        .padding(10)
                        .foregroundColor(.text)
                        .background(Color.white)
                    Divider().frame(height: 1).background(Color.nonActive)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                Spacer()
                
                Button(action: {
                    let result = self.viewModel.save(presetCell: presetCell, category: category, amount: amount, memo: memo)
                    
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
                    Text("プリセットを保存する").outlineStyle(size: 18)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .alert(item: $showingAlert) { item in
                    item.alert
                }
            }
            .padding(.top, 30)
            .padding(16)
        }
        .onAppear {
            if let presetCell = self.presetCell {
                self.category = presetCell.category
                self.amount   = "\(presetCell.amount)"
                self.memo     = presetCell.memo
            }
        }
    }
}
