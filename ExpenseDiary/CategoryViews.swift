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
    
    func getCategoryCells(type: RecordType) -> [CategoryCell] {
        self.categoryCells.filter{$0.type == type.rawValue}
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
    
    func move(type: RecordType, _ from: IndexSet, _ to: Int) {
        let categories = self.getCategoryCells(type: type)
        guard let source = from.first else {
            return
        }
        
        if source < to {
            print(source, to)
            for i in (source + 1)...(to - 1) {
                if let category = Category.getById(categories[i].id) {
                    Category.updateOrder(category: category, order: i)
                }
            }
            if let category = Category.getById(categories[source].id) {
                Category.updateOrder(category: category, order: to)
            }
        } else if source > to {
            print(source, to)
            var count = 0
            for i in (to...(source - 1)).reversed() {
                if let category = Category.getById(categories[i].id) {
                    Category.updateOrder(category: category, order: source + 1 - count)
                }
                count += 1
            }
            if let category = Category.getById(categories[source].id) {
                Category.updateOrder(category: category, order: to + 1)
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
            Text(editMode?.wrappedValue.isEditing == true ? "完了" : "編集").planeStyle(size: 14)
        }
    }
}

struct CategoryMenuView: View {
    @ObservedObject var viewModel = CategoryViewModel()
    let screen = UIScreen.main.bounds
    
    @State var type: RecordType = .expense
    @State var isShowing = false
    @State var selectedCategoryCell: CategoryCell?
    
    @State var showingAlert: AlertItem?
    @State var deleteTarget: CategoryCell?
    
    private func move(_ from: IndexSet, _ to: Int) {
        self.viewModel.move(type: self.type, from, to)
    }
    
    private func delete()
    {
        return
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
                                
                List {
                    let categoryCells = viewModel.getCategoryCells(type: type)
                    ForEach(categoryCells, id: \.id) { categoryCell in
                        HStack {
                            Image(categoryCell.icon.name)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 18, height: 18)
                                .foregroundColor(.nonActive)
                                .padding(.trailing, 2)
                            Text(categoryCell.name).planeStyle(size: 16)
                            Spacer()
                        }
                        .padding(6)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.selectedCategoryCell = categoryCell
                        }
                       // .deleteDisabled(true)
                    }
                    .onMove(perform: move)
                    .onDelete(perform: { indexSet in
                        guard let index = indexSet.first else {
                            return
                        }
                        self.deleteTarget = categoryCells[index]
                        self.showingAlert = AlertItem(alert: Alert(
                              title: Text("削除しますか?"),
                              message:Text("このカテゴリーで登録した記録やプリセットもすべて削除されます。"),
                              primaryButton: .cancel(Text("キャンセル")),
                              secondaryButton: .destructive(Text("削除"),
                              action: {
                                   self.viewModel.delete(categoryCell: self.deleteTarget)
                              })))
                    })
                }
                .sheet(item: $selectedCategoryCell) { categoryCell in
                    EditCategoryView(type: type, categoryCell: categoryCell)
                }
                .alert(item: $showingAlert) { item in
                    item.alert
                }
                .padding(.horizontal, 16)
            }
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
            EditCategoryView(type: type, categoryCell: nil)
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
    @State var showingAlert: AlertItem?
    
    var body: some View {
        ZStack {
            Color.backGround.ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    TextField("カテゴリー名", text: $name)
                        .foregroundColor(.text)
                        .padding(10)
                        .background(Color.white)

                    Divider().frame(height: 1).background(Color.nonActive)
                }
                .padding(.horizontal, 40)
                .padding(.top, 40)
                .padding(.bottom, 50)

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
                            self.showingAlert = AlertItem(
                                alert: Alert(
                                    title: Text(""),
                                    message: Text(error.message),
                                    dismissButton: .default(Text("OK"))))
                    }
                }) {
                    Text("保存する").outlineStyle(size: 18)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 20)
                .alert(item: $showingAlert) { item in
                    item.alert
                }
            }
        }
        .onAppear {
            if let categoryCell = self.categoryCell {
                self.name = categoryCell.name
                self.icon = categoryCell.icon
            }
        }
    }
}
