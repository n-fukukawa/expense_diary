//
//  CategoryViews.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/10.
//

import SwiftUI


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
            Color("backGround")
            VStack {
                HStack {
                    Picker(selection: $type, label: Text("支出収入区分")) {
                        ForEach(RecordType.all(), id: \.self) { recordType in
                            Text(recordType.name).style()
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 16)
                                
                List {
                    let categoryCells = viewModel.filterCategoryCells(type: type)
                    ForEach(categoryCells, id: \.id) { categoryCell in
                        HStack {
                            Image(categoryCell.icon.name)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.secondary)
                                .padding(.trailing, 4)
                            Text(categoryCell.name).style(.title3)
                            Spacer()
                        }
                        .padding(8)
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
            .frame(width: screen.width)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: { self.isShowing = true }) {
                    Text("作成").style()
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
    
    @State var isEditing = false
    
    var iconSize: CGFloat {
        self.screen.width * 0.15
    }
    
    var body: some View {
        ZStack {
            Color("backGround").ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    TextField("カテゴリー名", text: $name, onEditingChanged: { isEditing in
                        self.isEditing = isEditing
                      }).customTextField()

                    Divider().frame(height: 1).background(isEditing ? Color("themeLight") : Color.secondary)
                }
                .padding(.top, 20)
                .padding(.bottom, 50)

                ScrollView(showsIndicators: false) {
                    let columns: [GridItem] = Array(repeating: .init(.fixed(iconSize), spacing: iconSize * 0.5), count: 4)
                    
                    LazyVGrid(columns: columns, alignment: .center, spacing: iconSize * 0.5) {
                        ForEach(Icon.all(), id: \.self) { icon in
                            Button(action: { self.icon = icon }) {
                                let is_active = self.icon == icon
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(LinearGradient(gradient: Gradient(colors: [is_active ? Color("themeDark") : Color("backGround"), is_active ? Color("themeLight") : .white]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: iconSize * 0.85, height: iconSize * 0.85)
                                        .myShadow(radius: 3, x: 2, y: 2)
                                    Image(icon.name)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: iconSize * 0.45, height: iconSize * 0.45)
                                        .foregroundColor(is_active ? .white : .secondary)
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
                    Text("保存する").bold().style(color: .white)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.bottom, screen.width * 0.05)
                .alert(item: $showingAlert) { item in
                    item.alert
                }
            }
            .frame(width: screen.width * 0.8)
            .padding(.vertical, 40)

        }
        .onAppear {
            if let categoryCell = self.categoryCell {
                self.name = categoryCell.name
                self.icon = categoryCell.icon
            }
        }
    }
}
