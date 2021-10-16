//
//  ChartView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/09.
//

import SwiftUI

struct ChartView: View {
    @EnvironmentObject var env: StatusObject
    @State var recordType: RecordType = .expense
    @State var category: Category?
    var body: some View {
        return VStack { Spacer()
            Text("chart view").planeStyle(size: 20)
            Spacer() }
        VStack {
            HStack(spacing: 0) {
                    ForEach(RecordType.all(), id: \.self) { recordType in
                        Button(action: {
                            self.recordType = recordType
                            self.category = nil
                        }){
                            let is_active = self.recordType == recordType
                            VStack(spacing: 8) {
                                if is_active {
                                    Text(recordType.name).planeStyle(size: 16).foregroundColor(.main)
                                    Rectangle().frame(height: 3).offset(x: 0, y: -1)
                                } else {
                                    Text(recordType.name).planeStyle(size: 16).foregroundColor(.main)
                                    Rectangle().frame(height: 1)
                                }
                            }
                            .foregroundColor(.main)
                        }
                    }
            }.padding(.horizontal, 20)
            
            SelectionView(recordType: $recordType, category: $category)
                .padding(.bottom, 5)
                .padding(.top, 10)
            Divider()
            ChartBodyView(env: env, recordType: $recordType, category: $category)
                .padding(.horizontal, 10)
        }
    }
}

struct SelectionView: View {
    @Binding var recordType: RecordType
    @Binding var category: Category?
    @State var categories: Array<Category> = []
    
    var body: some View {
            ScrollView(.horizontal, showsIndicators:false) {
                HStack(spacing: 30) {
                    Button(action:{
                        self.category = nil
                    }) {
                        let is_active = self.category === nil
                        VStack(spacing: 5) {
                            ZStack {
                                Image("home2")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(is_active ? .darkMain : .nonActive)
                            }
                            Text("すべて").planeStyle(size: 14)
                                .foregroundColor(is_active ? .darkMain : .nonActive)
                        }
                    }.frame(minWidth: 40)
                    
                    ForEach(Category.getByType(self.recordType), id: \.self) { category in
                        Button(action:{
                            self.category = category
                        }) {
                            let is_active = category.id == self.category?.id
                            VStack(spacing: 5) {
                                ZStack {
                                    Image(category.icon.name)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(is_active ? .darkMain : .nonActive)
                                        .shadow(color: .main.opacity(is_active ? 0.3 : 0), radius: 8)
                                }
                                Text(category.name).bold().planeStyle(size: 13)
                                    .foregroundColor(is_active ? .darkMain : .nonActive)
                            }
                        }.frame(minWidth: 40)
                    }
                }
                .padding(.horizontal, 20)
            }
    }
}

struct ChartBodyView: View {
    @ObservedObject var env: StatusObject
    @Binding var recordType: RecordType
    @Binding var category: Category?
    
    let leadingPadding: CGFloat = 50
    @State private var currentLabel = ""
    @State private var currentValue = 0
    @State private var touchLocation: CGFloat = -1
    @State private var activeIndex: Int = 0
    @State private var labelPositionX: CGFloat = 0
    
    var barColor: Color = .main
    var data: [ChartData] = []
    
    init(env: StatusObject, recordType: Binding<RecordType>, category: Binding<Category?>) {
        self._recordType = recordType
        self._category = category
        self.env = env
        self.activeIndex = env.activeMonth - 1
        setData()
    }
    
    mutating func setData() {
        let monthTotal = Record.getYearly(dates: [Date():Date()], type: recordType, category: category)
        var count = 1
        monthTotal.forEach({ value in
            self.data.append(ChartData(label : "\(count)月", value: value))
            count += 1
        })
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
    
    var body: some View {
        if !data.isEmpty {
            VStack {
                ZStack {
                    Color.darkMain.cornerRadius(5)
                    HStack {
                        Text(currentLabel).bold().outlineStyle(size: 12)
                        Spacer()
                        Text("\(currentValue) 円").bold().outlineStyle(size: 14)
                        Text(">").outlineStyle(size: 12)
                    }
                    .padding(.vertical, 6).padding(.horizontal, 12)
                }
                .position(x: labelPositionX)
                .frame(width: 180)
                .frame(height: 40)
                .padding(.top, 20)
                .padding(.bottom, 10)
            
                GeometryReader { geometry in
                    ZStack {
                        let lineCount = getLineCount()
                        ForEach(0..<lineCount + 1) { index in
                            Text("\(getMarginedMax() / lineCount * (lineCount - index))")
                                .planeStyle(size: 12)
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
                                }
                            }
                        }
                        .onAppear() {
                            updateLabel(width: 3)
                        }
                        .padding(.leading, leadingPadding)
                    }
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 30)
        }
    }
}
