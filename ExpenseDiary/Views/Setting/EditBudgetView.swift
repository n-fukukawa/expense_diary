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
    
    @State var success = false
    
    private func close() {
        self.presentationMode.wrappedValue.dismiss()
    }
    
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            NavigationView {
                ZStack {
                // 背景
                    Color("backGround").ignoresSafeArea(.all)
                    
                    // Success Flash
                    VStack (spacing: 20) {
                        Image("yen")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color(env.themeLight))
                        
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
                                        .frame(width: screen.width * 0.45)
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
                        .padding(.horizontal, screen.width * 0.08)
                        .padding(.vertical, screen.width * 0.05)
                    }
                    .alert(item: $showingAlert) { item in
                        item.alert
                    }
            }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar{
                    ToolbarItem(placement: .cancellationAction) {
                        HStack {
                            Button(action: { self.close() }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(env.themeDark))
                                Text("戻る").fontWeight(.regular).foregroundColor(Color(env.themeDark))
                            }
                        }
                    }
                }
            }
        }
        .onAppear() {
            self.showSettingMenu = false
        }
    }

}
