//
//  EditOtherView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/12/04.
//

import SwiftUI

struct EditOtherView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var env: StatusObject
    
    func change() {
        self.env.refreshActive()
    }
    
    let weekdays: [Int : String] = [
        1 : "日",
        2 : "月",
        3 : "火",
        4 : "水",
        5 : "木",
        6 : "金",
        7 : "土",
    ]
    
    private func close() {
        self.env.setViewType(.home)
    }
    
    var body: some View {
        ZStack {
            Color("backGround").ignoresSafeArea(.all)
            VStack {
                HStack {
                    Button(action: { self.close() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(env.themeDark))
                        Text("戻る").fontWeight(.regular).foregroundColor(Color(env.themeDark))
                    }
                    .padding(.leading, 16)
                    Spacer()
                }
                Divider()
                
                NavigationView {
                    Form {
                        Section(header: Text("カレンダー")) {
                            Picker("月の開始日", selection: $env.startDay) {
                                ForEach(1...28, id: \.self) { day in
                                    Text("\(day) 日")
                                        .padding(.trailing, 4)
                                }
                            }
                            .onChange(of: env.startDay) { _ in
                                self.change()
                            }
                            
                            if env.startDay != 1 {
                                Picker("\(env.month)月度", selection: $env.forward) {
                                    ForEach((0...1).reversed(), id: \.self) { index in
                                        let nextMonth = env.month + 1 > 12 ? 1  : env.month + 1
                                        let prevMonth = env.month - 1 < 1  ? 12 : env.month - 1
                                        Text(index == 0
                                                ? "\(env.month)月\(env.startDay)日〜\(nextMonth)月\(env.startDay - 1)日"
                                                : "\(prevMonth)月\(env.startDay)日〜\(env.month)月\(env.startDay - 1)日" )
                                            .padding(.trailing, 4)
                                    }
                                }
                                .onChange(of: env.forward) { bool in
                                    self.change()
                                }
                            }
                            
                            Picker("週の開始曜日", selection: $env.startWeekday) {
                                ForEach(1...7, id: \.self) { index in
                                    Text("\(weekdays[index]!)")
                                        .padding(.trailing, 4)
                                }
                            }
                        }
                        
                        Section(header: Text("テーマ")) {
                            Picker("テーマカラー", selection: $env.themeId) {
                                ForEach(Theme.all().map{$0.id}, id: \.self) { themeId in
                                    if let theme = Theme.find(id: themeId) {
                                        HStack {
                                            Rectangle()
                                                .frame(width: 14, height: 14)
                                                .foregroundColor(Color(theme.colorSetDark))
                                            Text(theme.name)
                                        }.padding(.trailing, 4)
                                    }
                                }
                            }
                        }
                    }
                    .navigationBarHidden(true)
                    .navigationTitle("")
                }
                .accentColor(Color(env.themeDark))

            }
        }
    }
}
