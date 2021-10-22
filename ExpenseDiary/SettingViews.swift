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
    
    var body: some View {
        if isActive {
            HStack {
                ZStack {
                    Color.backGround.ignoresSafeArea(.all)
                        .shadow(color: .black.opacity(0.1), radius: 20, x: 10, y: 20)
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: { self.isActive = false }){
                                Image(systemName: "xmark")
                                    .font(.system(size: 24, weight: .medium))
                            }
                        }
                        HStack {
                            Image(systemName: "gearshape.2")
                                .font(.system(size: 110, weight: .thin))
                                .foregroundColor(.nonActive)
                                .opacity(0.5)
                                .offset(x: -10)
                            Spacer()
                        }
                        .padding(.bottom, 30)
                        
                        VStack (spacing: 40) {
                            NavigationLink(destination: CategoryMenuView()) {
                                HStack {
                                    Text("カテゴリーの登録／編集").planeStyle(size: 15)
                                    Spacer()
                                }
                            }
                            NavigationLink(destination: EditStartDayView()) {
                                HStack {
                                    Text("月の開始日の変更").planeStyle(size: 15)
                                    Spacer()
                                }
                            }
                            NavigationLink(destination: PresetMenuView()) {
                                HStack {
                                    Text("プリセットの登録／編集").planeStyle(size: 15)
                                    Spacer()
                                }
                            }
                            NavigationLink(destination: EditThemeView()) {
                                HStack {
                                    Text("テーマカラーの変更").planeStyle(size: 15)
                                    Spacer()
                                }
                            }
                            NavigationLink(destination: BackUpMenuView()) {
                                HStack {
                                    Text("バックアップ＆引継ぎ").planeStyle(size: 15)
                                    Spacer()
                                }
                            }
                            NavigationLink(destination: Text("AppStore").foregroundColor(.text)) {
                                HStack {
                                    Text("レビュー").planeStyle(size: 15)
                                    Spacer()
                                }
                            }
                        }
                        Spacer()
                        Spacer()
    //                            Text("©︎fukulab 2021")
                    }
                    .foregroundColor(.text)
                    .padding(30)
                }
                .frame(width: screen.width * 0.8)
                
                Spacer()
            }
            .offset(x: self.isActive ? 0 : -screen.width)
            .animation(.default)
        }
    }
}



struct EditStartDayView: View {
    @EnvironmentObject var env: StatusObject
    
    func change() {
        self.env.refreshActive()
    }
    
    var body: some View {
        ZStack {
            Color.backGround
            VStack {
                Form {
                    Picker("月の開始日", selection: $env.startDay) {
                        ForEach(1...28, id: \.self) { day in
                            Text("\(day) 日")
                                .padding(.trailing, 10)
                        }
                    }
                    //.pickerStyle(WheelPickerStyle())
                    .foregroundColor(.text)
                    .onChange(of: env.startDay) { day in
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
                                    .padding(.trailing, 10)
                            }
                        }
                        //.pickerStyle(WheelPickerStyle())
                        .foregroundColor(.text)
                        .onChange(of: env.forward) { bool in
                            self.change()
                        }
                    }
                }
            }
        }
    }
}



struct EditThemeView: View {
    @EnvironmentObject var env: StatusObject
    
    init() {
        
    }
    var body: some View {
        ZStack {
            Color.backGround
            Form {
                Picker("", selection: $env.themeId) {
                    ForEach(Theme.all().map{$0.id}, id: \.self) { themeId in
                        if let theme = Theme.find(id: themeId) {
                            HStack {
                                Text(theme.name).planeStyle(size: 16)
                                Spacer()
                                HStack(spacing: 0) {
                                    Rectangle()
                                        .frame(width: 14, height: 14)
                                        .foregroundColor(Color(hex: theme.color1))
                                    Rectangle()
                                        .frame(width: 14, height: 14)
                                        .foregroundColor(Color(hex: theme.color2))
                                    Rectangle()
                                        .frame(width: 14, height: 14)
                                        .foregroundColor(Color(hex: theme.color3))
                                }
                                .border(Color(hex: "cccccc"), width: 1)
                            }
                        }
                    }
                }
                .labelsHidden()
                .foregroundColor(.text)
            }
        }
    }
}

struct BackUpMenuView: View {
    @State var theme: Theme = Theme()
    var body: some View {
        ZStack {
            Color.backGround
            VStack {
                Text("BackUp Menu")
            }
            .foregroundColor(.text)
        }
    }
}
