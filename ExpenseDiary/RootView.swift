//
//  ContentView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import SwiftUI
import RealmSwift

struct RootView: View {
    let screen = UIScreen.main.bounds
    let formatter = DateFormatter()
    
    @EnvironmentObject var env: StatusObject
    
    @State var mode: ViewMode = .home
    
    @State var showEdit = false
    @State var showSettingMenu = false
    @State var showPicker = false
    @State var contentType: ContentType = .records
    @State var showRing = false
    
    
    @State var lineChartRender: CGFloat = 0
    
    var showModal: Bool {
        self.showSettingMenu || self.showPicker
    }
    
    init() {
//        let realm = try! Realm()
//
//        try! realm.write {
//             realm.deleteAll()
//        }
//        Icon.seed()
//        Theme.seed()
//        ColorSet.seed()
//
//        Category.seed()
////        Budget.seed()
//        Record.seed()
    }

    var body: some View {
        
        NavigationView {
            ZStack (alignment: .top) {
                
                if mode == .home {
                    Color.backGround.ignoresSafeArea(.all)
                    
                    Rectangle().fill(LinearGradient(gradient: Gradient(colors: [.themeDark, .themeLight]), startPoint: .leading, endPoint: .trailing))
                        .frame(height: screen.height * 0.3)
                        .ignoresSafeArea(.all)
                    
                    VStack (spacing: 0) {
                        HeaderView(showSettingMenu: $showSettingMenu, showPicker: $showPicker)
                            .padding(.top, 10)
    //                            .opacity(env.viewType == .home ? 1 : 0)
                            .frame(maxWidth: screen.width - 50)
                        
                        GeometryReader { geometry in
                            BalanceView(height: 60 ,viewModel: BalanceViewModel(env: env))
                                .offset(y: env.viewType == .balance ? -geometry.frame(in: .global).minY : 0)
                        }
                        .frame(maxWidth: env.viewType == .balance ? .infinity : screen.width - 40)
                        .frame(height: 60)
    //                        .opacity(env.viewType == .home || env.viewType == .balance ? 1 : 0)
                        .zIndex(env.viewType == .balance ? 1 : 0)

                        
                        GeometryReader { geometry in
                            BudgetView(viewModel: BudgetViewModel(env: env))
                                .offset(y: env.viewType == .budget ? -geometry.frame(in: .global).minY : 0)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                        .zIndex(env.viewType == .budget ? 1 : 0)
                        //.opacity(env.viewType == .home || env.viewType == .budget  ? 1 : 0)
                        
                    }
                } else {
                    AnalysisView(viewModel: AnalysisViewModel(env: env))
                }

                Spacer(minLength: 50 + 60)
                
                VStack {
                    Spacer()
                    AdmobBannerView().frame(width: 320, height: 50)
                        .zIndex(2)
                    if env.viewType == .home {
                        HStack {
                            Spacer()
                            Button(action: {self.mode = .home}) {
                                Image("home2")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(true ? .themeDark : .secondary.opacity(0.4))
                            }
                            Spacer()
                            Button(action: {self.showEdit = true}) {
                                ZStack {
                                    Circle().fill(LinearGradient(gradient: Gradient(colors: [.themeDark, .themeLight]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .shadow(color: .themeDark.opacity(0.3), radius: 4, x: 0, y: 0)
                                        .shadow(color: .themeDark.opacity(0.8), radius: 1, x: 2, y: 2)
                                        .shadow(color: .themeLight.opacity(0.8), radius: 1, x: -1, y: -1)
                                    Image("pen")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.white)
                                        .frame(width: 24, height: 24)
                                }
                                .frame(width: 60, height: 60)
                            }
                            .sheet(isPresented: $showEdit) {
                                EditRecordView(record: nil)
                            }
                            Spacer()
                            Button(action: {self.mode = .chart}) {
                                Image(systemName: "chart.bar.xaxis")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(false ? .themeDark : .secondary.opacity(0.4))
                            }
                            Spacer()
                        }
                    }
                }

                SettingMenuView(isActive: $showSettingMenu).transition(.slide)

            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
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
        VStack (spacing: 4) {
            HStack (spacing: 12) {
                Button(action: { withAnimation() { self.showSettingMenu = true}})
                {
                    VStack (alignment: .leading, spacing: 8) {
                        ForEach(-1..<2) { i in
                            Rectangle()
                                .frame(width: 20 + CGFloat(abs(i)) * 6 , height: 2)
                                .foregroundColor(.backGround)
                        }
                    }
                }
                
                Button(action: { self.showPicker = true })
                {
                    HStack (alignment: .center, spacing: 1) {
                        Text("\(env.activeMonth)").style(.title, color: .white)
                        Text("月").style(color: .white).offset(y: 2)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.white)
                            .opacity(0.8)
                            .padding(.leading, 4)
                            .offset(y: 2)
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

struct NoDataView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("データがありません").style(.body).frame(maxWidth: .infinity)
            Spacer()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
//        let devices = ["iPhone 12", "iPhone 8 Plus", "iPad Air(4th generation)"]
        let devices = ["iPhone 12", "iPhone 8", "iPad (8th generation)"]
        ForEach(devices, id: \.self) { device in
            RootView().environmentObject(StatusObject())
                       .previewDevice(.init(rawValue: device))
                        .environment(\.locale, Locale(identifier: "ja_JP"))
        }
    }
}

