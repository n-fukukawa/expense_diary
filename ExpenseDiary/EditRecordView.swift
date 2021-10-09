//
//  EditRecordView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/05.
//

import SwiftUI

struct EditRecordView: View {
    let record: Record?
    @Binding var isActive: Bool
    @State var type: RecordType = .expense
    @State var date = Date()
    @State var category: Category?
    @State var categories = Category.getByType(.expense)
    @State var amount = ""
    @State var memo = ""
    let formatter = DateFormatter()
    
    init(isActive: Binding<Bool>, record: Record? = nil) {
        self._isActive = isActive
        self.record = record
        
        if let _record = self.record {
            self.amount = "\(_record.amount)"
            self.memo   = "\(_record.memo)"
        }
        
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d(E)"
    }
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
                                    Text(recordType.name).modifier(BoldText(size: 18))
                                    Rectangle().frame(height: 3).offset(x: 0, y: -1)
                                } else {
                                    Text(recordType.name).modifier(NormalText(size: 18))
                                    Rectangle().frame(height: 1)
                                }
                            }.foregroundColor(.text)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 36)
                
                Text(formatter.string(from: date)).tracking(2).modifier(BoldText(size: 24))
                    .foregroundColor(.text)
                    .padding(.bottom, 24)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 25) {
                        ForEach(categories, id: \.self) { category in
                            Button(action:{
                                self.category = category
                            }) {
                                VStack(spacing: 3) {
                                    ZStack {
                                        Circle().foregroundColor(category.name == self.category?.name ? .accent : .white)
                                            .frame(width: 50, height: 50)
                                            .shadow(color: .black.opacity(0.05), radius: 2)
                                        Image(category.icon)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 25, height: 25)
                                            .foregroundColor(category.name == self.category?.name ? .white : .nonActive)
                                    }
                                    .frame(width: 55, height: 55)
                                    Text(category.name).modifier(BoldText(size: 14))
                                        .foregroundColor(.text)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                }
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
                
                Button(action: {}) {
                    Text("保存する").modifier(BoldText(size: 18)) .foregroundColor(.backGround)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 30)

                if record != nil {
                    Button(action: {}) {
                        Text("削除する").modifier(BoldText(size: 18)).foregroundColor(.backGround)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .padding(.horizontal, 20)
                }
               
            }
            
            .padding(.vertical, 50)
        }
    }
}
