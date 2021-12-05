//
//  ContentView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import SwiftUI
import RealmSwift
import AppTrackingTransparency
import GoogleMobileAds

struct RootView: View {
    @EnvironmentObject var env: StatusObject
    let screen = UIScreen.main.bounds
    
    @State var mode: ViewMode = .home
    
    @State var showEdit = false
    @State var showSettingMenu = false
    
    @State var isSettingActive = false

    @State var showRing = false

    init () {
        UITableView.appearance().backgroundColor = UIColor(Color("backGround"))

        if #available(iOS 15.0, *) {
            // iOS 15 Fix: Because NavigationBar is transparent
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor(Color("backGround"))
            // iOS 15 Fix: For remove top padding of List section
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UITableView.appearance().sectionHeaderTopPadding = 0
            UITableViewHeaderFooterView.appearance().backgroundColor = UIColor(.secondary)
        }
    }
    
    private func requestIDFA() {
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in })
        }
    }
    
    var showModal: Bool {
        self.showSettingMenu
    }

    var body: some View {
        ZStack (alignment: .top) {
            if mode == .home {
                Color("backGround").ignoresSafeArea(.all)
                
                Rectangle().fill(LinearGradient(gradient: Gradient(colors: [Color(env.themeDark), Color(env.themeLight)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: env.showMonthPicker ? screen.height * 0.3 + 120 : screen.width * 0.6)
                    .ignoresSafeArea(.all)
                
                VStack (spacing: 8) {
                    HeaderView(showSettingMenu: $showSettingMenu, showPicker: $env.showMonthPicker)
                        .padding(.top, 5)
                        .frame(maxWidth: screen.width - 40)

                    GeometryReader { geometry in
                        BalanceView(height: 60 ,viewModel: BalanceViewModel(env: env))
                            .offset(y: env.viewType == .balance ? -geometry.frame(in: .global).minY : 0)
                    }
                    .frame(maxWidth: env.viewType == .balance ? .infinity : screen.width - 40)
                    .frame(height: 60)
                    .zIndex(env.viewType == .balance ? 1 : 0)
                    .offset(y: env.showMonthPicker ? 100 : 0)

                    GeometryReader { geometry in
                        BudgetView(viewModel: BudgetViewModel(env: env))
                            .offset(y: env.viewType == .budget ? -geometry.frame(in: .global).minY : 0)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .padding(.bottom, 20)
                    .zIndex(env.viewType == .budget ? 1 : 0)
                    .offset(y: env.showMonthPicker ? 100 : 0)
                    
                    GeometryReader { geometry in
                        CalendarView(viewModel: CalendarViewModel(env: env), height: 300)
                            .padding(.top, 10)
                    }
                    .offset(y: env.showMonthPicker ? 100 : 0)
                    .gesture(
                        DragGesture().onEnded{ value in
                            if value.translation.width > 50 {
                                self.env.movePrevMonth()
                            } else if value.translation.width < -50 {
                                self.env.moveNextMonth()
                            }
                        }
                    )
                }
                .transition(.opacity)
                .ignoresSafeArea(.keyboard)
                .gesture(
                    DragGesture()
                        .onChanged{ value in
                            if !env.showMonthPicker { return }
                            if value.translation.height < -80 {
                                withAnimation() {
                                    self.env.showMonthPicker = false
                                }
                            }
                        }
                        .onEnded{ value in
                            if !env.showMonthPicker { return }
                            if value.translation.height < -80 {
                                self.env.showMonthPicker = false
                            }
                        }
                )
            } else {
                AnalysisView(viewModel: AnalysisViewModel(env: env))
                    .transition(.opacity)
            }

            Spacer(minLength: 50 + 70)
            
            VStack {
                Spacer()
                AdmobBannerView().frame(width: 320, height: 50)
                    .padding(.bottom, 4)
                    .zIndex(2)
                if env.viewType == .home {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.4)) { self.mode = .home }
                        }) {
                            Image("home2")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(self.mode == .home ? Color(env.themeDark).opacity(0.8) : Color("secondary").opacity(0.4))
                        }
                        Spacer()
//                            NavigationLink(destination: EditRecordView(record: nil)) {
                            Button(action: {self.showEdit = true}) {
                                ZStack {
                                    Circle().fill(LinearGradient(gradient: Gradient(colors: [Color(env.themeDark), Color(env.themeLight)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .shadow(color: Color(env.themeDark).opacity(1), radius: 1, x: 1, y: 1)
                                        .shadow(color: Color(env.themeLight).opacity(0.8), radius: 1, x: -1, y: -1)
                                    Image(systemName: "plus")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.white)
                                        .frame(width: 16, height: 16)
                                }
                                .frame(width: 50, height: 50)
                        }
                            .sheet(isPresented: $showEdit) {
                                EditRecordView(record: nil).environmentObject(env)
                            }
//                            .navigationBarHidden(false)

                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.4)) {self.mode = .chart}
                        }) {
                            Image(systemName: "chart.bar.xaxis")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(self.mode == .chart ? Color(env.themeDark).opacity(0.8) : Color("secondary").opacity(0.4))
                        }
                        Spacer()
                    }
                    .padding(.bottom, 10)
                }
            }
            
            Color.black.opacity(showSettingMenu ? 0.4 : 0)
                .ignoresSafeArea(.all)
                .animation(.easeOut(duration: 0.4))
                .onTapGesture {
                    self.showSettingMenu = false
                }
            
            SettingMenuView(isActive: $showSettingMenu)
            
            if (env.viewType == .settingBudget) {
                EditBudgetView(env: env)
                    //.opacity(env.viewType == .settingBudget ? 1 : 0)
            } else if (env.viewType == .settingCategory) {
                CategoryMenuView()
                    //.opacity(env.viewType == .settingCategory ? 1 : 0)
            } else if (env.viewType == .settingPreset) {
                PresetMenuView()
                    //.opacity(env.viewType == .settingPreset ? 1 : 0)
            } else if (env.viewType == .settingCalendarTheme) {
                EditOtherView()
                    //.opacity(env.viewType == .settingCalendarTheme ? 1 : 0)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            self.requestIDFA()
        }
    }
}


struct HeaderView: View {
    let screen = UIScreen.main.bounds
    @EnvironmentObject var env: StatusObject
    @State var showEdit = false
    @Binding var showSettingMenu: Bool
    @Binding var showPicker: Bool
    let formatter = DateFormatter()
    let formatterWithYear = DateFormatter()
    
    init(showSettingMenu: Binding<Bool>, showPicker: Binding<Bool>) {
        self._showSettingMenu = showSettingMenu
        self._showPicker = showPicker
        formatter.dateFormat = "M-d"
        formatterWithYear.dateFormat = "Y-M-d"
    }
    var body: some View {
        ZStack (alignment: .top) {
            YearMonthPicker()
                .frame(maxWidth: screen.width - 40, maxHeight: showPicker ? 80 : 10, alignment: .top)
                .offset(y: showPicker ? 80 : 0)
                .opacity(showPicker ? 1 : 0)
            
            VStack (spacing: 4) {
                HStack (spacing: 12) {
                    Button(action: { self.showSettingMenu.toggle() })
                    {
                        VStack (alignment: .leading, spacing: 8) {
                            ForEach(-1..<2) { i in
                                Rectangle()
                                    .frame(width: 20 + CGFloat(abs(i)) * 6 , height: 1.5)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    
                    Button(action: { withAnimation() {
                        self.showPicker.toggle()
                        }
                    })
                    {
                        HStack (alignment: .center, spacing: 1) {
                            Text("\(env.activeMonth)").style(.title, color: .white)
                            Text("月").style(color: .white).offset(y: 3)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.white)
                                .opacity(0.8)
                                .padding(.horizontal, 4)
                                .offset(y: showPicker ? 0 : 2)
                                .rotationEffect(Angle(degrees: showPicker ? 180 : 0))
                            Spacer()
                        }
                    }
                    Spacer()
                }
                
                HStack (spacing: 0) {
                    Group {
                        Text("\(formatterWithYear.string(from: env.startDate))").style(.caption, tracking: 1, color: .white)
                        Text("〜").style(.caption2, tracking: 1, color: .white)
                        Text("\(formatter.string(from: env.endDate))").style(.caption, tracking: 1, color: .white)
                        Spacer()
                    }
                }
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let devices = ["iPhone 12", "iPhone 8", "iPhone SE", "iPad (8th generation)"]
        ForEach(devices, id: \.self) { device in
            RootView().environmentObject(StatusObject())
                       .previewDevice(.init(rawValue: device))
                        .environment(\.locale, Locale(identifier: "ja_JP"))
        }
    }
}


struct YearMonthPicker: View {
    let screen = UIScreen.main.bounds
    @EnvironmentObject var env: StatusObject
    
    var body: some View {
        VStack {
            HStack {
                Picker("年", selection: $env.activeYear) {
                    ForEach(1900...2100, id: \.self) { year in
                        Text("\(String(year))年")
                            .style(weight: .semibold, tracking: 1, color: .white)
                    }
                }
                .frame(width: 150, height: 80)
                .compositingGroup()
                .clipped()
                .pickerStyle(WheelPickerStyle())
                
                Picker("月", selection: $env.activeMonth) {
                    ForEach(1...12, id: \.self) { month in
                        Text("\(String(month))月")
                            .style(weight: .semibold, tracking: 1, color: .white)
                    }
                }
                .frame(width: 90, height: 80)
                .compositingGroup()
                .clipped()
                .pickerStyle(WheelPickerStyle())
                Spacer()
            }
            .contentShape(Rectangle())
        }
    }
}
