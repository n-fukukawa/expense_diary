//
//  CategoryViews.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/10.
//

import SwiftUI
import RealmSwift

class CategoryViewModel: ObservableObject {
    @Published var categoryCells: [CategoryCell] = []
    
    private var categories: Results<Category>
    private var notificationTokens: [NotificationToken] = []
    
    init() {
        self.categories = Category.all()
        self.setCategoryCells(categories: categories)
        
        notificationTokens.append(categories.observe { change in
            switch change {
                case let .initial(results):
                    self.setCategoryCells(categories: results)
                    print("changed")
                case let .update(results, _, _, _):
                    self.setCategoryCells(categories: results)
                    print("update")
                case let .error(error):
                    print(error.localizedDescription)
            }
        })
    }
    
    private func setCategoryCells(categories: Results<Category>) {
        self.categoryCells = categories.map {
            CategoryCell(id: $0.id, type: $0.type, name: $0.name, icon: $0.icon, order: $0.order, created_at: $0.created_at, updated_at: $0.updated_at)
        }
    }
    
    func save(categoryCell: CategoryCell?, type: RecordType, name: String, icon: Icon?)
        -> Result<Category, EditCategoryError>
    {
        // バリデーション
        if name.isEmpty {
            return .failure(.nameIsEmpty)
        }
        if name.count > Config.CATEGORY_NAME_MAX  {
            return .failure(.nameTooLong)
        }
        guard let icon = icon else {
            return .failure(.iconIsEmpty)
        }
        
        // 更新
        if let categoryCell = categoryCell {
            if let category = Category.getById(categoryCell.id) {
                let updateCategory = Category.update(category: category, name: name, icon: icon)
                return .success(updateCategory)
            }
            
            return .failure(.categoryNotFound)
        }
        
        // 新規作成
        let category = Category.create(type: type, name: name, icon: icon)

        return .success(category)
    }
    
    func delete(categoryCell: CategoryCell?) {
        if let categoryCell = categoryCell {
            if let category = Category.getById(categoryCell.id) {
                Category.delete(category)
            }
        }
    }
}

enum EditCategoryError : Error {
    case nameIsEmpty
    case nameTooLong
    case iconIsEmpty
    case categoryNotFound
    
    var message: String {
        switch self {
        case .nameIsEmpty       : return "カテゴリー名を入力してください"
        case .nameTooLong       : return "カテゴリー名は\(Config.CATEGORY_NAME_MAX)文字以内で入力してください"
        case .iconIsEmpty       : return "アイコンを選択してください"
        case .categoryNotFound  : return "カテゴリーがみつかりませんでした"
        }
    }
}

struct MyEditButton: View {
    @Environment(\.editMode) var editMode
    
    var body: some View {
        Button(action: {
            withAnimation {
                if editMode?.wrappedValue.isEditing == true {
                    editMode?.wrappedValue = .inactive
                } else {
                    editMode?.wrappedValue = .active
                }
            }
        }) {
            Image(systemName: editMode?.wrappedValue.isEditing == true
                    ? "checkmark" : "arrow.up.arrow.down")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
        }
    }
}

struct CategoryMenuView: View {
    @ObservedObject var viewModel = CategoryViewModel()
    @State var type = RecordType.expense
    @State var isShowing = false
    @State var selectedCategoryCell: CategoryCell?
    
    private func rowReplace(_ from: IndexSet, _ to: Int) {
        self.viewModel.categoryCells.move(fromOffsets: from, toOffset: to)
    }
    
    var body: some View {
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
                
                HStack {
                    Spacer()
                    MyEditButton().foregroundColor(.text)
                        .padding(.trailing, 20)
                }
                
                
                List {
                    ForEach(viewModel.categoryCells.filter{$0.type == self.type.rawValue}, id: \.id) { categoryCell in
                        HStack {
                            Image(categoryCell.icon.name)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 18, height: 18)
                                .foregroundColor(.nonActive)
                                .padding(.trailing, 2)
                            Text(categoryCell.name).planeStyle(size: 16)
                        }
                        .padding(6)
                        .onTapGesture {
                            self.selectedCategoryCell = categoryCell
                        }
                    }
                    .onMove(perform: rowReplace)
                }
                //.padding(.horizontal, 20)
                .sheet(item: $selectedCategoryCell) { categoryCell in
                    EditCategoryView(type: type, categoryCell: categoryCell)
                }
                
                Button(action: {self.isShowing = true}) {
                    Text("\(type.name)カテゴリーを作成").bold().outlineStyle(size: 18)
                }
                .buttonStyle(PrimaryButtonStyle())
                .sheet(isPresented: $isShowing) {
                    EditCategoryView(type: type, categoryCell: nil)
                }
                .padding(30)
            }
        }
    }
}


struct EditCategoryView: View {
    let type: RecordType
    let categoryCell: CategoryCell?
    @ObservedObject var viewModel = CategoryViewModel()
    @Environment(\.presentationMode) var presentationMode
    let screen = UIScreen.main.bounds
    
    @State var icon: Icon?
    @State var name = ""
    
    @State var error: EditCategoryError?
    
    @State var showError       = false
    @State var showConfirm     = false
    @State var showConfirmMore = false
    
    @State var deleteTarget: CategoryCell?
    
    var showModal: Bool {
        self.showError || self.showConfirm || self.showConfirmMore
    }
    
    var body: some View {
        ZStack {
            Color.backGround.ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    TextField("カテゴリー名", text: $name)
                        .foregroundColor(.text)
                        .padding(10)
                        .background(Color.white)
                        .deleteDisabled(true)

                    Divider().frame(height: 1).background(Color.nonActive)
                }
                .padding(.horizontal, 40)
                .padding(.top, 40)
                .padding(.bottom, 50)
                
//                HStack {
//                    Picker(selection: $type, label: Text("支出収入区分")) {
//                        ForEach(RecordType.all(), id: \.self) { recordType in
//                            Text(recordType.name).planeStyle(size: 16)
//                        }
//                    }
//                    .labelsHidden()
//                    .pickerStyle(SegmentedPickerStyle())
//                }
//                .padding(.horizontal, 40)
//                .padding(.bottom, 50)
                

                
                ScrollView(showsIndicators: false) {
                    let columns: [GridItem] = Array(repeating: .init(.fixed(50), spacing: 20), count: 5)
                    
                    LazyVGrid(columns: columns, alignment: .center, spacing: 20) {
                        ForEach(Icon.all(), id: \.self) { icon in
                            Button(action: { self.icon = icon }) {
                                let is_active = self.icon == icon
                                ZStack {
                                    Circle().foregroundColor(is_active ? .accent : .white)
                                        .frame(width: 50, height: 50)
                                        .shadow(color: .black.opacity(0.05), radius: 2)
                                    Image(icon.name)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(is_active ? .white : .nonActive)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)

                Spacer()

                Button(action: {
                    let result = self.viewModel.save(categoryCell: self.categoryCell, type: self.type, name: self.name, icon: self.icon)
                    
                    switch result {
                        case .success(_):
                            self.presentationMode.wrappedValue.dismiss()
                        case .failure(let error):
                            self.error = error
                            self.showError = true
                    }
                }) {
                    Text("保存する").outlineStyle(size: 20)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                // 削除ボタン
                if let categoryCell = categoryCell {
                    Button(action: {
                        self.showConfirm = true
                        self.deleteTarget = categoryCell
                    }) {
                        Text("削除する").bold().planeStyle(size: 16)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 30)
            
            // モーダル背景
            ZStack {
                Color.black.opacity(self.showModal ? 0.3 : 0).ignoresSafeArea(.all)
                    .animation(Animation.easeIn)
            }
            .onTapGesture {
                self.showError = false
                self.showConfirm = false
                self.showConfirmMore = false
            }
            
            // エラー
            if let error = self.error {
                VStack(spacing: 0) {
                    Text(error.message).planeStyle(size: 18)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 30)
                    Divider()
                    Button(action: { self.showError = false }) {
                        Text("OK").planeStyle(size: 18)
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(width: screen.width * 0.9)
                .modifier(ModalCardModifier(active: showError))
            }
            
            // 削除確認
            VStack(spacing: 0) {
                Text("このカテゴリーで登録した記録もすべて削除されます。削除しますか？").planeStyle(size: 18)
                    .lineSpacing(5)
                    .padding(.horizontal, 30)
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
                        self.showConfirm = false
                        self.showConfirmMore = true
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
            
            // 削除再確認
            VStack(spacing: 0) {
                Text("削除後はもとに戻せません。本当に削除しますか？").planeStyle(size: 18)
                    .lineSpacing(5)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 40)
                Divider()
                HStack(spacing: 0) {
                    Button(action: {
                            self.showConfirmMore = false
                        
                    }) {
                        Text("キャンセル").bold().outlineStyle(size: 20)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                    }
                    .background(Color.nonActive)
                    Button(action: {
                        self.viewModel.delete(categoryCell: self.deleteTarget)
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
            .modifier(ModalCardModifier(active: showConfirmMore))
        }
        .onAppear {
            if let categoryCell = self.categoryCell {
                self.name = categoryCell.name
                self.icon = categoryCell.icon
            }
        }
    }
}
