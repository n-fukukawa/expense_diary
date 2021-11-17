//
//  BalanceView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/23.
//

import SwiftUI

struct BalanceView: View {
    @Environment(\.colorScheme) var colorScheme
    let screen = UIScreen.main.bounds
    let height: CGFloat
    @EnvironmentObject var env: StatusObject
    @ObservedObject var viewModel: BalanceViewModel
    
    var show: Bool {
        self.env.viewType == .balance
    }
    
    var scale: CGFloat {
        self.show ? 4.4 : 1.0
    }
    
    var headerHeight: CGFloat {
        self.show ? height * scale
                  : height
    }
    
    var contentHeight: CGFloat {
        self.show ? screen.height : headerHeight
    }
    
    var pad: CGFloat {
        self.headerHeight * 0.12
    }
    
    var width: CGFloat {
        self.show ? screen.width : screen.width - 40
    }
    
    let formatter = DateFormatter()
    
    init(height: CGFloat, viewModel: BalanceViewModel) {
        self.height = height
        self.viewModel = viewModel
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = Config.MONTH_DAY_DESC
    }
    
    func onClickBackward() {
        if viewModel.viewState == .category {
            viewModel.onChangeCategory(category: nil)
        } else {
            self.close()
        }
    }
    
    func onClickBalance() {
        if show {
            viewModel.onChangeRecordType(recordType: nil)
        } else {
            self.open()
        }
    }
    
    func open() {
        self.env.onChangeViewType(.balance)
    }
    
    func close() {
        self.viewModel.onChangeCategory(category: nil)
        self.viewModel.onChangeRecordType(recordType: nil)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)) {
            self.env.onChangeViewType(.home)
        }
    }
    
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ZStack (alignment: .top) {
                if show {
                Rectangle().fill(LinearGradient(gradient: Gradient(colors: [Color(env.themeDark), Color(env.themeLight)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: headerHeight)
                
                List {
                    if viewModel.viewState == .summary {
                        if !viewModel.summary.isEmpty {
                            ForEach(viewModel.summary, id: \.key) { summary in
                                ForEach(summary.value, id: \.key) { s in
                                    SummaryCardView(category: s.key, amount: s.value).id(summary.key)
                                    .listRowInsets(EdgeInsets())
                                    .onTapGesture {
                                        self.viewModel.onChangeCategory(category: s.key)
                                    }
                                }
                            }
                        } else {
                            NoDataView().listRowInsets(EdgeInsets())
                        }
                    } else {
                        if !viewModel.recordCells.isEmpty {
                            ForEach(viewModel.recordCells, id: \.key) { date, recordCells in
                                Section (header:
                                            RecordSectionHeaderView(date: date, recordCells: recordCells)) {
                                    ForEach(recordCells, id: \.id) { recordCell in
                                        RecordCardView(recordCell: recordCell).id(recordCell.id)
                                        .listRowInsets(EdgeInsets())
                                    }
                                }.id(date)
                            }
                            .onAppear() {
                                if let targetDate = self.env.balanceViewDate {
                                    viewModel.recordCells.forEach({ date, recordCells in
                                        if date == targetDate {
                                            scrollProxy.scrollTo(date, anchor: .center)
                                            return
                                        }
                                    })
                                    self.env.balanceViewDate = nil
                                }
                            }
                        } else {
                            NoDataView().listRowInsets(EdgeInsets())
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .frame(maxWidth: width, maxHeight: contentHeight, alignment: .top)
                .padding(.bottom, headerHeight + 100)
                .background(Color("backGround"))
                .offset(y: show ? headerHeight : 0)
                .opacity(show ? 1 : 0)
                .zIndex(show ? 1 : 0)
                }
            
                GeometryReader { geometry in
                    VStack {
                        //戻る矢印
                        if show {
                        HStack {
                            Image(systemName: "arrow.backward")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .contentShape(Rectangle())
                                .offset(x: -20)
                                .onTapGesture { self.onClickBackward() }
                            Spacer()
                        }}
                        //収支
                        Button (action: {
                                    if !self.show {
                                        self.open()
                                    } else {
                                        onClickBalance()
                                    }})
                        {
                            HStack (alignment: .center) {
                                Spacer()
                                VStack (alignment: .center, spacing: 8) {
                                    if viewModel.viewState == .category {
                                        Image(viewModel.category!.icon.name)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: headerHeight * 0.18)
                                            .foregroundColor(.white)
                                        Text(viewModel.category!.name)
                                            .style(weight: .medium, tracking: 3, color: .white)
                                            .padding(.bottom, 4)
                                    }
                                    HStack {
                                        Text(viewModel.viewState == .category
                                            ? "\(viewModel.categoryAmount)"
                                            : "\(viewModel.balance > 0 ? "+" : (viewModel.balance < 0 ? "−" : ""))\(abs(viewModel.balance))")
                                        .style(.largeTitle, color: .white)
                                        .scaleEffect(1.1)
                                        Text("円").style(weight: .regular, color: .white).offset(y: 4)
                                        if !show {
                                            Image(systemName: "chevron.right")
                                                .font(.title3)
                                                .foregroundColor(.white)
                                                .padding(.leading, 4)
                                        }
                                    }
                                    .padding(.leading, 8)
                                }
                                if show { Spacer() }
                            }
                        }
                        
                        // 支出と収入
                        if show && viewModel.category == nil {
                            Rectangle().foregroundColor(.white.opacity(0.5)).frame(height: 1)
                            HStack (spacing: 20) {
                                VStack (spacing: 4) {
                                    Text("支出").style(.caption, weight: .bold, color: .white)
                                        .offset(x: -8)
                                    HStack (spacing: 6) {
                                        Text("\(viewModel.spending)円").style(.body, weight: .medium, tracking: 1, color: .white)
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(12)
                                .background(Color.white.opacity(viewModel.recordType == .expense ? 0.2 : 0))
                                .cornerRadius(5)
                                .onTapGesture {
                                    viewModel.onChangeRecordType(recordType: .expense)
                                }
                                
                                VStack (spacing: 6) {
                                    Text("収入").style(.caption, weight: .bold, color: .white)
                                        .offset(x: -8)
                                    HStack (spacing: 6) {
                                        Text("\(viewModel.income)円").style(.body, weight:.medium, tracking: 1, color: .white)
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(12)
                                .background(Color.white.opacity(viewModel.recordType == .income ? 0.2 : 0))
                                .cornerRadius(5)
                                .onTapGesture {
                                    viewModel.onChangeRecordType(recordType: .income)
                                }
                            }
                        }
                    }
                    .padding(pad)
                    .padding(.top, show ? 30 : 0)
                }
                .frame(maxWidth: width, maxHeight: headerHeight)
                .ignoresSafeArea(.all)
                .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.5))
            }
        }
        .frame(height: contentHeight)
        .animation(.easeInOut(duration: 0.4))
        .ignoresSafeArea(.all)
        .gesture(
            DragGesture()
            .onEnded { value in
                if value.translation.width > 50 {
                    if viewModel.category == nil {
                        if viewModel.recordType != nil {
                            viewModel.onChangeRecordType(recordType: nil)
                        } else {
                            self.close()
                        }
                    } else {
                        viewModel.onChangeCategory(category: nil)
                    }
                }
            }
        )
    }
}


struct BalanceView_Previews: PreviewProvider {
    static var previews: some View {
        let devices = ["iPhone 12", "iPhone 8"]
        ForEach(devices, id: \.self) { device in
            BalanceView(height: 80, viewModel: BalanceViewModel(env: StatusObject()))
                       .previewDevice(.init(rawValue: device))
                        .environment(\.locale, Locale(identifier: "ja_JP"))
        }
    }
}

