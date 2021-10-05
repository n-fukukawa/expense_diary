//
//  ContentView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var env: StatusObject
    var body: some View {
        ZStack {
            Color.main.ignoresSafeArea(.all)
            VStack {
                HeaderView().padding(.horizontal, 30)
                
                TabView().padding(.bottom, 10).padding(.horizontal, 10)
                
                SelectionView(env: env).padding(.leading, 20).padding(.bottom, 5)
                
                MainView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootView().environmentObject(StatusObject())
    }
}

struct HeaderView: View {
    @EnvironmentObject var env: StatusObject
    @State var isShowing = false
    var body: some View {
        HStack {
            if env.navItem == .list {
                HStack {
                    Text("10").modifier(BoldText(size: 40))
                    
                    VStack(alignment: .leading) {
                        Text("2021")
                        HStack(spacing: 3) {
                            Text("9/26")
                            Text("-")
                            Text("10/25")
                        }
                    }.modifier(NormalText(size: 14))
                }
            } else {
                HStack {
                    Text("2021").tracking(2).modifier(BoldText(size: 40))
                }
            }
            
            Spacer()
            Button(action: { self.isShowing = true }){
                Image(systemName: "gearshape")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
            }
            .fullScreenCover(isPresented: $isShowing) {
                SettingMenuView(isActive: $isShowing)
            }
        }
        .foregroundColor(.white)
    }
}



struct TabView: View {
    @EnvironmentObject var env: StatusObject
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.all(), id: \.self) { tabItem in
                Button(action: {
                    self.env.tabItem = tabItem
                    self.env.category = nil
                }){
                    let is_active = self.env.tabItem == tabItem
                    VStack(spacing: 8) {
                        if is_active {
                            Text(tabItem.rawValue).modifier(BoldText(size: 18))
                            Rectangle().frame(height: 3).offset(x: 0, y: -1)
                        } else {
                            Text(tabItem.rawValue).modifier(NormalText(size: 18))
                            Rectangle().frame(height: 1)
                        }
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct SelectionView: View {
    @ObservedObject var env: StatusObject
    let categories: Array<Category>
    
    init(env: StatusObject) {
        self.env = env
        self.categories = Category.getByType(env.tabItem.type)
    }
    var body: some View {
        if env.tabItem != .balance {
            ScrollView(.horizontal, showsIndicators:false) {
                HStack(spacing: 30) {
                    Button(action:{
                        self.env.category = nil
                    }) {
                        VStack(spacing: 3) {
                            ZStack {
                                Circle().foregroundColor(self.env.category === nil ? .accent : .backGround)
                                Image("home2")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(self.env.category === nil ? .white : .darkMain)
                            }
                            .frame(width: 40, height: 40)
                            Text("すべて").modifier(BoldText(size: 14))
                                .foregroundColor(.white)
                        }
                    }
                    ForEach(categories, id: \.self) { category in
                        Button(action:{
                            self.env.category = category
                        }) {
                            VStack(spacing: 3) {
                                ZStack {
                                    Circle().foregroundColor(category.name == self.env.category?.name ? .accent : .backGround)
                                    Image(category.icon)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(category.name == self.env.category?.name ? .white : .darkMain)
                                }
                                .frame(width: 40, height: 40)
                                Text(category.name).modifier(BoldText(size: 14))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding(.trailing, 20)
            }
            .onAppear() {
                
            }
        }
    }
}

struct MainView: View {
    var body: some View {
        ZStack {
            Rectangle().cornerRadius(25.0, corners: [.topLeft, .topRight])
                .ignoresSafeArea(edges: .bottom)
                .foregroundColor(.backGround)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: -2)
            
            VStack {
                ContentView().padding(.horizontal, 20).padding(.top, 20)
                
                Spacer()
                
                AdmobBannerView().frame(width: 320, height: 50)
                
                GlobalNavView()
            }
        }
    }
}



struct ContentView: View {
    @EnvironmentObject var env: StatusObject

    var body: some View {
        if(env.navItem == .list) {
            ListView(env: env)
        } else {
            GraphView()
        }
    }
}

struct ListView: View {
    @ObservedObject var env: StatusObject
    let monthlyRecords: [Date: Array<Record>]?
    var total = 0
    
    init(env: StatusObject) {
        self.env = env
        self.monthlyRecords = Record.getMonthly(type: env.tabItem.type, category: env.category)
        if let _monthlyRecords = self.monthlyRecords {
            _monthlyRecords.forEach({ date, dailyRecord in
                dailyRecord.forEach({ record in
                    total += record.amount
                })
            })
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("\(total) 円").tracking(2).modifier(NormalText(size: 24))
                    .foregroundColor(.text)
            }
            .padding(10)
            
            if let _monthlyRecords = monthlyRecords {
                ScrollView(showsIndicators: false) {
                    VStack {
                        ForEach(Array(_monthlyRecords.keys.sorted(by: >)), id: \.self) { date in
                            DailyCard(date: date, records: _monthlyRecords[date]!)
                        }
                    }
                }
            } else {
                Spacer()
                Text("データがありません").modifier(NormalText(size: 16)).foregroundColor(.text)
                Spacer()
            }
        }
    }
}

struct DailyCard: View {
    let date: Date
    let records: Array<Record>
    let dateFormatter = DateFormatter()
    var total = 0
    
    init(date: Date, records: Array<Record>) {
        self.date = date
        self.records = records
        self.dateFormatter.locale = Locale(identifier: "ja_JP")
        self.dateFormatter.dateFormat = "M/d E"
        records.forEach({ record in
            self.total += record.amount
        })
    }
    var body: some View {
        VStack(spacing: 5) {
            HStack(spacing: 10) {
                Text("\(dateFormatter.string(from: date))")
                    .tracking(2).modifier(NormalText(size: 16))
                Text("\(total) 円")
                    .tracking(1).modifier(NormalText(size: 12))
                Rectangle().frame(height: 1).foregroundColor(.nonActive)
            }
            .padding(.bottom, 10)
            
            VStack(spacing: 8) {
                ForEach(records) { record in
                    Button(action: {}) {
                        ZStack {
                            Color.white
                                .cornerRadius(5)
                                .shadow(color: .black.opacity(0.05), radius: 1, x: 1, y: 1)
                                
                            HStack {
                                Text(record.category?.name ?? "未分類")
                                    .tracking(2).modifier(NormalText(size: 16))
                                Text(record.memo)
                                    .tracking(2).modifier(NormalText(size: 12))
                                Spacer()
                                Text("\(record.amount) 円")
                                    .tracking(2).modifier(NormalText(size: 16))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                        }
                    }
                    .sheet(isPresented: $isShowing) {
                        EditRecordView()
                    }
                }
            }
        }
        .foregroundColor(.text)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
    //    var body: some View {
    //        ZStack {
    //            Color.white.shadow(color: .black.opacity(0.1), radius: 2, x: 1, y: 1)
    //            VStack(spacing: 5) {
    //                HStack(spacing: 10) {
    //                    Text("\(dateFormatter.string(from: date))").tracking(2).modifier(NormalText(size: 16))
    //                    Text("\(total) 円").tracking(2).modifier(NormalText(size: 12))
    //                    Spacer()
    //                }
    //                .padding(.bottom, 10)
    //
    //                ForEach(records) { record in
    //                    HStack {
    //                        Text(record.category?.name ?? "未分類").tracking(2).modifier(NormalText(size: 16))
    //                        Text(record.memo).tracking(2).modifier(NormalText(size: 12))
    //                        Spacer()
    //                        Text("\(record.amount) 円").tracking(2).modifier(NormalText(size: 16))
    //                    }
    //                }
    //            }
    //            .padding(16)
    //        }
    //    }
}


struct GraphView: View {
    @State private var currentLabel = ""
    @State private var currentValue = ""
    
    @State private var touchLocation: CGFloat = -1
    
    var barColor: Color = .main
    var data: [ChartData] = [
        ChartData(label: "1月", value : 0),
        ChartData(label: "2月", value : 0),
        ChartData(label: "3月", value : 0),
        ChartData(label: "4月", value : 3500),
        ChartData(label: "5月", value : 4000),
        ChartData(label: "6月", value : 3500),
        ChartData(label: "7月", value : 500),
        ChartData(label: "8月", value : 5500),
        ChartData(label: "9月", value : 2500),
        ChartData(label: "10月", value : 3500),
        ChartData(label: "11月", value : 1500),
        ChartData(label: "12月", value : 2500),
    ];
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    Color.main.cornerRadius(5)
                    HStack {
                        Text(currentLabel)
                        Spacer()
                        Text("\(currentValue) 円").tracking(1)
                    }.modifier(BoldText(size: 16)).foregroundColor(.white)
                    .padding(.vertical, 6).padding(.horizontal, 12)
                }.frame(width: 150).frame(maxHeight: 30)
                VStack {
                    HStack(spacing: 15) {
                        ForEach(0..<data.count, id: \.self) { i in
                            BarChartCell(value: normalizedValue(index: i), barColor: .main)
                                .padding(.top)
                                .opacity(barIsTouched(index: i) ? 1 : 0.7)
                                .scaleEffect(barIsTouched(index: i) ? CGSize(width: 1.05, height: 1) : CGSize(width: 1, height: 1), anchor: .bottom)
                                .animation(.spring())
                        }
                    }
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged({ position in
                            touchLocation = position.location.x/geometry.frame(in: .local).width
                            updateCurrentValue()
                        })
                        .onEnded({ position in
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                                withAnimation(Animation.easeOut(duration: 0.5)) {
//                                    resetValues()
//                                }
//                            }
                        })
                    )
                    
                    if !currentLabel.isEmpty {
                        Text(currentLabel).foregroundColor(.text)
                            .offset(x: labelOffset(in: geometry.frame(in: .local).width))
                    }
                }.padding(.top, 40)
            }
        }
        .padding(.top, 30)
    }
    
    func normalizedValue(index: Int) -> Double {
             var allValues: [Int]    {
                 var values = [Int]()
                 for data in data {
                    values.append(data.value)
                 }
                 return values
             }
             guard let max = allValues.max() else {
                 return 1
             }
             if max != 0 {
                 return Double(data[index].value) / Double(max)
             } else {
                 return 1
             }
    }
    
    func updateCurrentValue()    {
             let index = Int(touchLocation * CGFloat(data.count))
             guard index < data.count && index >= 0 else {
                 currentValue = ""
                 currentLabel = ""
                 return
             }
             currentValue = "\(data[index].value)"
             currentLabel = data[index].label
         }
    
    func resetValues() {
             touchLocation = -1
             currentValue  =  ""
             currentLabel = ""
    }
    
    func labelOffset(in width: CGFloat) -> CGFloat {
             let currentIndex = Int(touchLocation * CGFloat(data.count))
             guard currentIndex < data.count && currentIndex >= 0 else {
                 return 0
             }
             let cellWidth = width / CGFloat(data.count)
             let actualWidth = width -    cellWidth
             let position = cellWidth * CGFloat(currentIndex) - actualWidth/2
             return position
    }
    
    func barIsTouched(index: Int) -> Bool {
        touchLocation > CGFloat(index)/CGFloat(data.count) && touchLocation < CGFloat(index+1)/CGFloat(data.count)
    }
}


struct GlobalNavView: View {
    @EnvironmentObject var env: StatusObject
    @State var isShowing = false
    var body: some View {
        HStack {
            Button(action: {
                self.env.navItem = .list
            }){
                Image(systemName: "list.bullet")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(self.env.navItem == .list ? .main : .nonActive)
            }
            Spacer()
            Button(action: {
                self.isShowing = true
            }){
                ZStack {
                    Circle().foregroundColor(.yellow)
                    Text("+").foregroundColor(.white).modifier(BoldText(size: 28))
                }
                .frame(width: 50, height: 50)
            }
            .sheet(isPresented: $isShowing) {
                EditRecordView(isActive: $isShowing)
            }
            Spacer()
            Button(action: {
                self.env.navItem = .chart
            }){
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 30, weight: .thin))
                    .foregroundColor(self.env.navItem == .chart ? .main : .nonActive)
            }
        }
        .padding(.horizontal, 40)
    }
}

