//
//  SettingViews.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/05.
//

import SwiftUI

struct SettingMenuView: View {
    @Binding var isActive: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.main.ignoresSafeArea(.all)
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { self.isActive = false }){
                            Image(systemName: "xmark")
                                .font(.system(size: 24, weight: .medium))
                        }
                    }
                    Spacer()
                    VStack(spacing: 40){
                        NavigationLink(destination: CategoryMenuView()) {
                            Text("カテゴリーの登録／編集").outlineStyle(size: 18)
                        }
                        NavigationLink(destination: EditStartDayView()) {
                            Text("月の開始日の変更").outlineStyle(size: 18)
                        }
                        NavigationLink(destination: PresetMenuView()) {
                            Text("プリセットの登録／編集").outlineStyle(size: 18)
                        }
                        NavigationLink(destination: EditThemeView()) {
                            Text("テーマカラーの変更").outlineStyle(size: 18)
                        }
                        NavigationLink(destination: BackUpMenuView()) {
                            Text("バックアップ＆引継ぎ").outlineStyle(size: 18)
                        }
                        NavigationLink(destination: Text("AppStore").foregroundColor(.text)) {
                            Text("レビュー").outlineStyle(size: 18)
                        }
                    }
                    
                    Spacer()
                    Spacer()
                    Text("©︎fukulab 2021")
                }
                .foregroundColor(.white)
                .padding(30)
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}



struct EditStartDayView: View {
    @State var day = 1
    var body: some View {
        ZStack {
            Color.backGround
            VStack {
                Form {
                    Picker("月の開始日", selection: $day) {
                        ForEach(1..<32, id: \.self) { index in
                            Text("\(index) 日").planeStyle(size: 16)
                                .padding(.trailing, 10)
                        }
                    }
                    .foregroundColor(.text)
                }
            }
        }
    }
}



struct EditThemeView: View {
    @State var theme: Theme = Theme()
    var body: some View {
        ZStack {
            Color.backGround
            Form {
                Picker("", selection: $theme) {
                    ForEach(Theme.all(), id: \.self) { theme in
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
