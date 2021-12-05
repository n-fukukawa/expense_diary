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
    
    private func closeSettingMenu() {
        self.isActive = false
    }
    
    var body: some View {
        HStack {
            ZStack {
                Color("backGround").ignoresSafeArea(.all)
                VStack {
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
                            Text("予算").style(tracking: 1)
                            Spacer()
                        }
                        .onTapGesture {
                            self.env.setViewType(.settingBudget)
                            self.closeSettingMenu()
                        }
                        
                        HStack {
                            Text("カテゴリー").style(tracking: 1)
                            Spacer()
                        }
                        .onTapGesture {
                            self.env.setViewType(.settingCategory)
                            self.closeSettingMenu()
                        }
                        
                        HStack {
                            Text("固定収支").style(tracking: 1)
                            Spacer()
                        }
                        .onTapGesture {
                            self.env.setViewType(.settingPreset)
                            self.closeSettingMenu()
                        }
                        
                        HStack {
                            Text("カレンダー／テーマ").style(tracking: 1)
                            Spacer()
                        }
                        .onTapGesture {
                            self.env.setViewType(.settingCalendarTheme)
                            self.closeSettingMenu()
                        }
                        
                        
//                        HStack {
//                            NavigationLink(destination: Text("AppStore")) {
//                                Text("レビュー").style(tracking: 1)
//                            }
//                            Spacer()
//                        }
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




