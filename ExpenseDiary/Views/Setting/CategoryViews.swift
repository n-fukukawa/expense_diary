//
//  CategoryViews.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/10.
//

import SwiftUI


struct CategoryMenuView: View {
    @EnvironmentObject var env: StatusObject
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.editMode) var editMode
    @ObservedObject var viewModel = CategoryViewModel()
    let screen = UIScreen.main.bounds
    
    @State var type: RecordType = .expense
    @State var isShowing = false
    @State var selectedCategoryCell: CategoryCell?
    
    @State var showingAlert: AlertItem?
    @State var deleteTarget: CategoryCell?
    
    @State var updateId = UUID()
    
    private func move(_ from: IndexSet, _ to: Int) {
        self.viewModel.move(type: self.type, from, to)
    }
    
    private func delete()
    {
        return
    }
    
    private func close() {
        self.env.setViewType(.home)
    }
    
    var body: some View {
        ZStack (alignment: .top) {
            Color("backGround").ignoresSafeArea(.all)
            NavigationView {
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
                                    .foregroundColor(Color("secondary")).opacity(0.8)
                                    .padding(.trailing, 4)
                                Text(categoryCell.name).style(.body)
                                Spacer()
                            }
    //                            }
                            .padding(.vertical, 8)
//                            .listRowBackground()
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.selectedCategoryCell = categoryCell
                            }
                        }
                        .onMove(perform: self.move)
                        .onDelete(perform: { indexSet in
                            guard let index = indexSet.first else {
                                return
                            }
                            self.deleteTarget = categoryCells[index]
                            self.showingAlert = AlertItem(alert: Alert(
                                  title: Text("削除しますか?"),
                                  message:Text("このカテゴリーで登録した記録、予算、固定収支もすべて削除されます。"),
                                  primaryButton: .cancel(Text("キャンセル")),
                                  secondaryButton: .destructive(Text("削除"),
                                  action: {
                                       self.viewModel.delete(categoryCell: self.deleteTarget)
                                  })))
                        })
                    }
                    .listStyle(PlainListStyle())
                    .sheet(item: $selectedCategoryCell) { categoryCell in
                        EditCategoryView(type: type, categoryCell: categoryCell).environmentObject(env)
                    }
                    .alert(item: $showingAlert) { item in
                        item.alert
                    }
                    .padding(.horizontal, 16)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: { self.close() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .medium))
                            Text("戻る")
                        }
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: { self.isShowing = true }) {
                            Text("作成").fontWeight(.regular)
                        }
                            MyEditButton()
                        }
                    }
            }
            .accentColor(Color(env.themeDark))
        }
        .sheet(isPresented: $isShowing) {
            EditCategoryView(type: type, categoryCell: nil).environmentObject(env)
        }

    }
}


struct EditCategoryView: View {
    let type: RecordType
    let categoryCell: CategoryCell?
    @EnvironmentObject var env: StatusObject
    @ObservedObject var viewModel = EditCategoryViewModel()
    @Environment(\.presentationMode) var presentationMode
    let screen = UIScreen.main.bounds
    
    @State var icon: Icon?
    @State var name = ""
    @State var showingAlert: AlertItem?
    
    @State var isEditing = false
    
    @State var success = false
    
    var iconSize: CGFloat {
        self.screen.width * 0.15
    }
    
    var body: some View {
        ZStack {
            Color("backGround").ignoresSafeArea(.all)
            
//             Success Flash
            VStack (spacing: 20) {
                if let icon = self.icon {
                    Image("\(icon.name)")
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
               Color.primary.opacity(success ? 0.16 : 0).ignoresSafeArea(.all)
           }
           .zIndex(success ? 2 : 0)
            
            VStack(spacing: 0) {
                Rectangle().foregroundColor(.secondary)
                    .frame(width: 100, height: 4)
                    .padding(.bottom, 20)
                
                VStack(spacing: 0) {
                    TextField("カテゴリー名", text: $name, onEditingChanged: { isEditing in
                        self.isEditing = isEditing
                      }).customTextField()

                    Divider().frame(height: 1).background(isEditing ? Color(env.themeLight) : Color("secondary"))
                }
                .padding(.top, 20)
                .padding(.bottom, 50)

                ScrollViewReader { scrollProxy in
                    ScrollView(showsIndicators: false) {
                        let columns: [GridItem] = Array(repeating: .init(.fixed(iconSize), spacing: iconSize * 0.5), count: 4)
                        
                        LazyVGrid(columns: columns, alignment: .center, spacing: iconSize * 0.5) {
                            ForEach(Icon.all(), id: \.self) { icon in
                                Button(action: { self.icon = icon }) {
                                    let is_active = self.icon == icon
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(LinearGradient(gradient: Gradient(colors: [is_active ? Color(env.themeDark) : Color("iconBackground"), is_active ? Color(env.themeLight) : Color("iconBackground")]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .frame(width: iconSize * 0.85, height: iconSize * 0.85)
                                            .shadow(color: .black.opacity(0.1), radius: 3, x: 2, y: 2)
                                        Image(icon.name)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: iconSize * 0.45, height: iconSize * 0.45)
                                            .foregroundColor(is_active ? .white : Color("darkGray"))
                                    }
                                }
                                .id(icon.id)
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 10)
                    }
                    .padding(.bottom, 40)
                    .onAppear() {
                        if let categoryCell = self.categoryCell {
                            scrollProxy.scrollTo(categoryCell.icon.id, anchor: .center)
                        }
                    }
                }


                Spacer()

                Button(action: {
                    let result = self.viewModel.save(categoryCell: self.categoryCell, type: self.type, name: self.name, icon: self.icon)
                    
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
            .padding(.top, 20)
            .padding(.bottom, 40)
            .zIndex(1)

        }
        .onAppear {
            if let categoryCell = self.categoryCell {
                self.name = categoryCell.name
                self.icon = categoryCell.icon
            }
        }
    }
}
