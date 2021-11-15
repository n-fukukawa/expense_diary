//
//  SettingViews.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/05.
//

import SwiftUI

struct SettingMenuView: View {
    @EnvironmentObject var env: StatusObject
    @Binding var isActive: Bool
    let screen = UIScreen.main.bounds
    
    @State var dragValue: CGFloat = 0
    
    var body: some View {
        HStack {
            ZStack {
                Color("backGround").ignoresSafeArea(.all)
                VStack {
                    //                    HStack {
                    //                        Spacer()
                    //                        Button(action: {self.isActive = false})
                    //                        {
                    //                            Image(systemName: "xmark")
                    //                                .font(.system(size: 24, weight: .medium))
                    //                        }
                    //                    }
                    HStack {
                        Image(systemName: "gearshape.2")
                            .font(.system(size: 110, weight: .ultraLight))
                            .foregroundColor(Color("secondary"))
                            .opacity(0.5)
                            .offset(x: -10)
                        Spacer()
                    }
                    .padding(.bottom, 30)
                    
                    VStack (spacing: 40) {
                        
                        HStack {
                            NavigationLink(destination: EditBudgetView(env: env, showSettingMenu: $isActive)) {
                                Text("予算").style(tracking: 1)
                            }
                            Spacer()
                        }
                        
                        HStack {
                            NavigationLink(destination: CategoryMenuView(showSettingMenu: $isActive)) {
                                Text("カテゴリー").style(tracking: 1)
                            }
                            Spacer()
                        }
                        
                        
                        HStack {
                            NavigationLink(destination: PresetMenuView(showSettingMenu: $isActive)) {
                                Text("固定支出／収入").style(tracking: 1)
                            }
                            Spacer()
                        }
                        
                        
                        HStack {
                            NavigationLink(destination: EditOtherView(showSettingMenu: $isActive)) {
                                Text("カレンダー／テーマ").style(tracking: 1)
                            }
                            Spacer()
                        }
                        
                        HStack {
                            NavigationLink(destination: Text("AppStore")) {
                                Text("レビュー").style(tracking: 1)
                            }
                            Spacer()
                        }
                    }
                    Spacer()
                    Spacer()
                }
                .padding(30)
            }
            .frame(width: screen.width * 0.8)
            
            Spacer()
        }
        .offset(x: self.isActive ? dragValue : -screen.width)
        .animation(.easeOut(duration: 0.4))
        .gesture(
            DragGesture()
                .onChanged{value in
                    if value.translation.width < 0 {
                        self.dragValue = value.translation.width
                    }
                }
                .onEnded{value in
                    if self.dragValue < -50 {
                        self.isActive = false
                    }
                    
                    self.dragValue = .zero
                }
        )
    }
}



struct EditOtherView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var env: StatusObject
    @Binding var showSettingMenu: Bool
    
    init(showSettingMenu: Binding<Bool>) {
        self._showSettingMenu = showSettingMenu
    }
    
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
        self.presentationMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("カレンダー").padding(.top, 24)) {
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
                    .onChange(of: env.startWeekday) { _ in
                        //                        self.change()
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
            
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
        .accentColor(Color(env.themeDark))
        .onAppear() {
            self.showSettingMenu = false
        }
    }
}
