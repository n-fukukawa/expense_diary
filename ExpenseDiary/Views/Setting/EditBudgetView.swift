//
//  EditRecordView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/05.
//

import SwiftUI
import RealmSwift

struct EditBudgetView: View {
    @ObservedObject var env: StatusObject
    @ObservedObject var viewModel: EditBudgetViewModel
    @Binding var showSettingMenu: Bool
    let screen = UIScreen.main.bounds
    let budgetCell: BudgetCell?

    @Environment(\.presentationMode) var presentationMode
    let formatter = DateFormatter()

    @State var showDatePicker = false
    @State var deleteTarget: BudgetCell?
    @State var showingAlert: AlertItem?

    @State var category: Category?
    @State var amount = ""
    
    @State var isEditing = false
    
    var iconSize: CGFloat {
        self.screen.width * 0.2
    }
    
    init(budgetCell: BudgetCell? = nil, env: StatusObject, showSettingMenu: Binding<Bool>) {
        self.budgetCell = budgetCell
        self.env = env
        self.viewModel = EditBudgetViewModel(env: env)
        self._showSettingMenu = showSettingMenu
        
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M-d E"
    }
    
    @State var amounts: [(key: CategoryCell, value: String)] = []
    
    private func close() {
        self.presentationMode.wrappedValue.dismiss()
    }
    
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ZStack {
            // 背景
                Color("backGround").ignoresSafeArea(.all)
            
                VStack(spacing: 20) {

                    Form {
                        Section(header: HStack {
                            Spacer()
                            Text("\(String(env.activeYear))年\(env.activeMonth)月度の予算")
                                .style(.title3)
                            Spacer()
                        }.padding()
                        ) {
                            ForEach(viewModel.categoryCells.indices) { i in
                                HStack {
                                    HStack {
                                        Text("\(viewModel.categoryCells[i].name)").style()
                                        Spacer()
                                    }
                                    .frame(width: screen.width * 0.4)
                                    TextField("未設定", text: $amounts[i].value)
                                        .multilineTextAlignment(.trailing)
                                        .customTextField()
                                        .keyboardType(.numbersAndPunctuation)
                                }
                                .frame(height: screen.height * 0.05)
                            }
                        }
                    }
                    .onAppear() {
                        self.viewModel.categoryCells.forEach({ categoryCell in
                            var new: (key: CategoryCell, value: String)
                            if let budgetCell = self.viewModel.budgetCells
                                .filter({ $0.category.id == categoryCell.id}).first {
                                new = (key: categoryCell, value: "\(String(budgetCell.amount))")
                            } else {
                                new = (key: categoryCell, value: "")
                            }
                            self.amounts.append(new)
                        })
                    }

                    // 保存ボタン
                    Button(action: {                        
                        let result = self.viewModel.save(amounts: self.amounts, year: env.activeYear, month: env.activeMonth)
                            
                        switch result {
                            case .success(_):
                                self.close()
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
                    .padding(.horizontal, screen.width * 0.08)
                    .padding(.vertical, screen.width * 0.05)
                }
                //.padding(.vertical, 40)
                //.frame(width: screen.width * 0.9)
                .alert(item: $showingAlert) { item in
                    item.alert
                }
        }
            .onAppear {
//                if let budgetCell = self.budgetCell {
//                    self.category = budgetCell.category
//                    self.amount   = "\(budgetCell.amount)"
//                    self.year     = budgetCell.year
//                    scrollProxy.scrollTo(budgetCell.category.id)
//                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: { self.close()} )
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
