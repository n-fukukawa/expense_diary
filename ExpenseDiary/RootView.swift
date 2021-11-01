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
                    Color("backGround").ignoresSafeArea(.all)
                    
                    Rectangle().fill(LinearGradient(gradient: Gradient(colors: [Color("themeDark"), Color("themeLight")]), startPoint: .leading, endPoint: .trailing))
                        .frame(height: screen.height * 0.3)
                        .ignoresSafeArea(.all)
                    
                    VStack (spacing: 0) {
                        HeaderView(showSettingMenu: $showSettingMenu, showPicker: $showPicker)
                            .padding(.top, 10)
    //                            .opacity(env.viewType == .home ? 1 : 0)
                            .frame(maxWidth: screen.width - 40)
                        
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
                        
                       // GeometryReader { geometry in
                            CalendarView(viewModel: CalendarViewModel(env: env), height: 300)
                                .padding(.top, 10)
                                .gesture(
                                    DragGesture()
                                        .onChanged{value in
                                            
                                        }
                                        .onEnded{value in
                                            self.env.movePrevMonth()
                                        }
                                )
                       // }
                    }
                } else {
                    AnalysisView(viewModel: AnalysisViewModel(env: env))
                        .transition(.opacity)
                }

                Spacer(minLength: 50 + 70)
                
                VStack {
                    Spacer()
                    AdmobBannerView().frame(width: 320, height: 50)
                        .zIndex(2)
                    if env.viewType == .home {
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.6)) { self.mode = .home }
                            }) {
                                Image("home2")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(self.mode == .home ? Color("themeDark") : .secondary.opacity(0.4))
                            }
                            Spacer()
                            Button(action: {self.showEdit = true}) {
                                ZStack {
                                    Circle().fill(LinearGradient(gradient: Gradient(colors: [Color("themeDark"), Color("themeLight")]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .shadow(color: Color("themeDark").opacity(0.3), radius: 4, x: 0, y: 0)
                                        .shadow(color: Color("themeDark").opacity(0.8), radius: 1, x: 2, y: 2)
                                        .shadow(color: Color("themeLight").opacity(0.8), radius: 1, x: -1, y: -1)
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
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.6)) {self.mode = .chart}
                            }) {
                                Image(systemName: "chart.bar.xaxis")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(self.mode == .chart ? Color("themeDark") : .secondary.opacity(0.4))
                            }
                            Spacer()
                        }
                    }
                }
                
                Color.primary.opacity(showSettingMenu ? 0.2 : 0)
                    .ignoresSafeArea(.all)
                    .animation(.easeOut(duration: 0.4))
                    .onTapGesture {
                        self.showSettingMenu = false
                    }

                SettingMenuView(isActive: $showSettingMenu)
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CalendarView: View {
    let screen = UIScreen.main.bounds
    @ObservedObject var viewModel: CalendarViewModel
    @State var showEdit = false
    @State var selectedIndex: Int = 0
    
    let height: CGFloat
    
    var body: some View {
        VStack (spacing: 0) {
            let columns: [GridItem] = Array(repeating: .init(.fixed(screen.width / 7), spacing: 0), count: 7)
        
            // 曜日
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color("themeDark"), Color("themeLight")]), startPoint: .leading, endPoint: .trailing)
                LazyVGrid(columns: columns) {
                    let header = self.viewModel.getCalendarHeader()
                    ForEach(header, id: \.self) { week in
                        Text(week)
                            .style(.caption, color: .white)
                    }
                }
            }
            .frame(width: screen.width, height: 20)
            
            // 本体
            GeometryReader { geometry in
                ZStack {
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(viewModel.amounts, id: \.key) { date, amount in
                            let expense = amount[.expense]!
                            let income = amount[.income]!
                            Button(action: {
                                if !viewModel.isSameMonth(date) {
                                    return
                                }
                                self.showEdit = true
                            }) {
                                ZStack {
                                    VStack {
                                        HStack {
                                            Text(String(date.day))
                                                .style(.caption, weight: .medium, tracking: 0, color: viewModel.isSameMonth(date) ? .secondary : .secondary.opacity(0.3))
                                                .scaleEffect(1.1)
                                                .padding(.leading, 4)
                                                .padding(.top, 2)
                                            Spacer()
                                        }
                                        Spacer()
                                        HStack {
                                            VStack (spacing: 0) {
                                                Text("\(income)")
                                                    .style(.caption, tracking: 0, color: Color("themeDark"))
                                                    .opacity(viewModel.isSameMonth(date) && income != 0 ? 1 : 0)
                                                    .scaleEffect(0.8)
                                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                                Text("\(expense)")
                                                    .style(.caption, tracking: 0, color:  .primary.opacity(0.6))
                                                    .opacity(viewModel.isSameMonth(date) && expense != 0 ? 1 : 0)
                                                    .scaleEffect(0.8)
                                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                            }
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .border(Color.secondary.opacity(0.4), width: 0.5)
                                }
                                .frame(height: (geometry.frame(in: .local).height - 120 - 20) / 6)
                            }
                            .sheet(isPresented: $showEdit) {
                                EditRecordView(clickedDate: date)
                            }
                        }
                    }
                    .border(Color.secondary.opacity(0.4), width: 0.5)
                }
            }
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
                Button(action: { self.showSettingMenu = true })
                {
                    VStack (alignment: .leading, spacing: 8) {
                        ForEach(-1..<2) { i in
                            Rectangle()
                                .frame(width: 20 + CGFloat(abs(i)) * 6 , height: 1.5)
                                .foregroundColor(.white)
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

