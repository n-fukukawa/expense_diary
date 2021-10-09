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
            VStack(spacing: 0) {
                HeaderView().padding(.horizontal, 30).padding(.bottom, 16)
                MainView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let devices = ["iPhone 8 Plus", "iPhone 12", "iPad Air(4th generation)"]
        
        ForEach(devices, id: \.self) { device in
            RootView().environmentObject(StatusObject())
                       .previewDevice(.init(rawValue: device))
        }
    }
}

struct HeaderView: View {
    @EnvironmentObject var env: StatusObject
    @State var isShowing = false
    var body: some View {
        HStack {
            if env.navItem == .list {
                HStack {
                    Text("10").modifier(BoldText(size: 36))
                    
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
                    Text("2021").tracking(1).modifier(NormalText(size: 36))
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
            ForEach(RecordType.all(), id: \.self) { recordType in
                Button(action: {
                    self.env.recordType = recordType
                    self.env.category = nil
                }){
                    let is_active = self.env.recordType == recordType
                    VStack(spacing: 8) {
                        if is_active {
                            Text(recordType.name).modifier(BoldText(size: 18))
                            Rectangle().frame(height: 3).offset(x: 0, y: -1)
                        } else {
                            Text(recordType.name).modifier(NormalText(size: 18))
                            Rectangle().frame(height: 1)
                        }
                    }
                    .foregroundColor(.main)
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
        self.categories = Category.getByType(env.recordType)
    }
    var body: some View {
            ScrollView(.horizontal, showsIndicators:false) {
                HStack(spacing: 30) {
                    Button(action:{
                        self.env.category = nil
                    }) {
                        let is_active = self.env.category === nil
                        VStack(spacing: 5) {
                            ZStack {
                                // Circle().foregroundColor(self.env.category === nil ? .accent : .backGround)
                                Image("home2")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(is_active ? .darkMain : .nonActive)
                            }
                            Text("すべて").modifier(BoldText(size: 14))
                                .foregroundColor(is_active ? .darkMain : .nonActive)
                        }
                    }
                    ForEach(categories, id: \.self) { category in
                        Button(action:{
                            self.env.category = category
                        }) {
                            let is_active = category.name == self.env.category?.name
                            VStack(spacing: 5) {
                                ZStack {
                                    //Circle().foregroundColor(category.name == self.env.category?.name ? .backGround : .backGround)
                                    Image(category.icon)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(is_active ? .darkMain : .nonActive)
                                        .shadow(color: .main.opacity(is_active ? 0.3 : 0), radius: 8)
                                }
                                Text(category.name).modifier(BoldText(size: 13))
                                    .foregroundColor(is_active ? .darkMain : .nonActive)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
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
                ContentView()
                
                 Spacer()
                
                 AdmobBannerView().frame(width: 320, height: 50).padding(.bottom, 10)
                
                 GlobalNavView()
            }
        }
    }
}



struct ContentView: View {
    @EnvironmentObject var env: StatusObject
    
    var body: some View {
        if(env.navItem == .list) {
            ListView(env: env).padding(.horizontal, 16).padding(.top, 16)
        } else {
            TabView().padding(.vertical, 16)
            SelectionView(env: env).padding(.bottom, 5)
            Divider()
            ChartView(env: env).padding(.horizontal, 16)
        }
    }
}

struct ListView: View {
    @ObservedObject var env: StatusObject
    @State var isSummary = false
    let monthlyRecords: [Date: Array<Record>]?
    let summary: [Category: Int]?
    var expense = 0
    var income = 0
    var balance = 0

    init(env: StatusObject) {
        self.env = env
        self.monthlyRecords = Record.getMonthly(type: nil, category: nil)
        self.summary = Record.getSummary(year: 2021, month: 10)
        if let _monthlyRecords = self.monthlyRecords {
            _monthlyRecords.forEach({ date, dailyRecord in
                dailyRecord.forEach({ record in
                    if record.type == RecordType.expense.rawValue {
                        self.expense += record.amount
                    } else if record.type == RecordType.income.rawValue {
                        self.income += record.amount
                    }
                })
            })
            self.balance = self.income - self.expense
        }
    }
    
    var body: some View {
        let diaryString = "記録"
        let summaryString = "まとめ"
        HStack(spacing: 0) {
                Button(action: {
                    self.isSummary = false
                }){
                    VStack(spacing: 8) {
                        if isSummary {
                            Text(diaryString).tracking(2).modifier(NormalText(size: 18))
                            Rectangle().frame(height: 1).offset(x: 0, y: -1)
                        } else {
                            Text(diaryString).tracking(2).modifier(BoldText(size: 18))
                            Rectangle().frame(height: 3).offset(x: 0, y: -1)
                        }
                    }
                    .foregroundColor(.main)
                }
            
                Button(action: {
                    self.isSummary = true
                }){
                    VStack(spacing: 8) {
                        if isSummary {
                            Text(summaryString).tracking(2).modifier(BoldText(size: 18))
                            Rectangle().frame(height: 3).offset(x: 0, y: -1)
                        } else {
                            Text(summaryString).tracking(2).modifier(NormalText(size: 18))
                            Rectangle().frame(height: 1).offset(x: 0, y: -1)
                        }
                    }
                    .foregroundColor(.main)
                }
        }
        
        VStack {
            if isSummary {
                VStack {
                    Text("\(balance) 円").tracking(2).modifier(NormalText(size: 24))
                        .foregroundColor(.text)
                    HStack {
                        Spacer()
                        Text("\(expense) 円").tracking(2).modifier(NormalText(size: 20))
                            .foregroundColor(.text)
                        Spacer()
                        Text("\(income) 円").tracking(2).modifier(NormalText(size: 20))
                            .foregroundColor(.text)
                        Spacer()
                    }
                    .padding(10)
                }
                if let _summary = summary {
                    ScrollView(showsIndicators: false) {
                        VStack {
                            ForEach(Array(_summary.keys), id: \.self) { cate in
                                ListCard(name: cate.name, memo: "", amount: _summary[cate] ?? 0)
                            }
                        }
                    }
                }
                
            } else {
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
}

struct DailyCard: View {
    @State var isShowing = false
    @State var selectedRecord: Record?
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
            .foregroundColor(.text)
            .padding(.bottom, 10)
            
            VStack(spacing: 8) {
                ForEach(records) { record in
                    Button(action: {
                        self.isShowing = true
                        self.selectedRecord = record
                    }) {
                        ListCard(name: record.category?.name, memo: record.memo, amount: record.amount)
                    }
                    .sheet(item: $selectedRecord) { rec in
                        EditRecordView(isActive: $isShowing, record: rec)
                    }
                }
            }
        }
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

struct ListCard: View {
    let name: String?
    let memo: String
    let amount: Int
    var body: some View {
        ZStack {
            Color.white
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.05), radius: 1, x: 1, y: 1)
            
            HStack {
                Text(name ?? "未分類")
                    .tracking(2).modifier(NormalText(size: 16))
                Text(memo)
                    .tracking(2).modifier(NormalText(size: 12))
                Spacer()
                Text("\(amount) 円")
                    .tracking(2).modifier(NormalText(size: 16))
            }
            .foregroundColor(.text)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
    }
}


struct ChartView: View {
    @ObservedObject var env: StatusObject
    let leadingPadding: CGFloat = 50
    @State private var currentLabel = ""
    @State private var currentValue = 0
    
    @State private var touchLocation: CGFloat = -1
    
    @State private var activeIndex: Int = 0
    
    @State private var labelPositionX: CGFloat = 0
    
    var barColor: Color = .main
    var data: [ChartData] = []
    
    init(env: StatusObject) {
        self.env = env
        setData()
    }
    
    mutating func setData() {
        let monthTotal = Record.getMonthTotal(year: 2021, month: 10, type: env.recordType, category: env.category)
        
        var count = 1
        monthTotal.forEach({ value in
            self.data.append(ChartData(label : "\(count)月", value: value))
            count += 1
        })
    }
    
    var body: some View {
            VStack {
                ZStack {
                    Color.darkMain.cornerRadius(5)
                    HStack {
                        Text(currentLabel)
                        Spacer()
                        Text("\(currentValue) 円").tracking(1)
                    }
                    .modifier(BoldText(size: 16)).foregroundColor(.white)
                    .padding(.vertical, 6).padding(.horizontal, 12)
                }
                .position(x: labelPositionX)
                .frame(width: 150).frame(maxHeight: 30)
                .padding(.top, 10)
                

                
                GeometryReader { geometry in
                ZStack {
                    let lineCount = getLineCount()
                    ForEach(0..<lineCount + 1) { index in
                        Text("\(getMarginedMax() / lineCount * (lineCount - index))")
                            .modifier(NormalText(size: 12))
                            .foregroundColor(.nonActive)
                            .position(x: geometry.frame(in: .local).minX + 16,
                                      y: geometry.frame(in: .local).maxY / CGFloat(lineCount) * CGFloat(index) - 10)
                        Rectangle()
                            .foregroundColor(.nonActive)
                            .frame(height: 1)
                            .position(x: geometry.frame(in: .local).midX,
                                      y: geometry.frame(in: .local).maxY / CGFloat(lineCount) * CGFloat(index))
                    }
                
                    HStack(spacing: 0) {
                        ForEach(0..<data.count, id: \.self) { i in
                            VStack(spacing: 0) {
                                BarChartCell(value: normalizedValue(index: i), barColor: barIsTouched(index: i) ? .darkMain : .main)
                                    .scaleEffect(barIsTouched(index: i)
                                                    ? CGSize(width: 1.05, height: 1)
                                                    : CGSize(width: 1, height: 1), anchor: .bottom)
                                    .animation(.spring())
                                    .padding(.horizontal, 6)
                                    .gesture(DragGesture(minimumDistance: 0)
                                                .onChanged({ position in
                                                    self.activeIndex = i
                                                    updateLabel(width: geometry.frame(in: .local).midX)
                                                })
                                )

//                                    Text(data[i].label)
//                                        .modifier(NormalText(size: 10))
//                                        .foregroundColor(.text)
//                                        .overlay(
//                                        Text("\( geometry.frame(in: .local).height)")
//                                        )
//                                        .modifier(NormalText(size: geometry.frame(in: .local).size.height))
                            }
                        }
                    }
                    .onAppear() {
                        
                        updateLabel(width: 3)
                    }
//                    .gesture(DragGesture(minimumDistance: 0)
//                                .onChanged({ position in
//                                    touchX = position.location.x
//                                    touchLocation = position.location.x/geometry.frame(in: .local).width
//                                    updateCurrentValue()
//                                })
                    .padding(.leading, leadingPadding)
                }
            }
        }
        .padding(.top, 30)
        .padding(.bottom, 10)

    }
    
    func normalizedValue(index: Int) -> Double {
        let max = getMax()
        
        if max != 0 {
            let marginedMax = self.getMarginedMax()
            return Double(data[index].value) / Double(marginedMax)
        } else {
            return 1
        }
    }
    
    func getMax() -> Int {
        var allValues: [Int]    {
            var values = [Int]()
            for data in data {
                values.append(data.value)
            }
            return values
        }
        
        guard let max = allValues.max() else {
            return 0
        }
        
        return max
    }
    
    func getMarginedMax() -> Int {
        let max = getMax()
        
        let digit = String(max).count
        let divided = Double(max + 1) / pow(Double(10), Double(digit - 1))
        
        let initial = Int(divided.rounded(.up))
        
        return Int(Double(initial) * pow(Double(10), Double(digit - 1)))
    }
    
    func getLineCount() -> Int {
        let max = getMax()

        let digit = String(max).count
        
        if digit < 3 {
            return 1;
        }
        
        let divided = Double(max + 1) / pow(Double(10), Double(digit - 1))
        
        let initial = Int(divided.rounded(.up))
        
        switch(initial) {
        case 1: return 4;
        case 2: return 4;
        case 3: return 6
        case 4: return 4;
        case 5: return 5;
        case 6: return 6;
        case 7: return 7;
        case 8: return 4;
        case 9: return 3;
        case 10: return 4;
        default: return 1;
        }
    }
    
    func updateLabel(width: CGFloat)    {
        currentValue = data[self.activeIndex].value
        currentLabel = data[self.activeIndex].label
        
        labelPositionX = CGFloat(self.activeIndex) / CGFloat(data.count - 1) * width
        print (labelPositionX)
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
        self.activeIndex == index
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



