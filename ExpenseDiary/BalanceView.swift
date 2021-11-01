//
//  BalanceView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/23.
//

import SwiftUI

struct BalanceView: View {
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
        formatter.dateFormat = "M-d"
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
                Rectangle().fill(LinearGradient(gradient: Gradient(colors: [Color("themeDark"), Color("themeLight")]), startPoint: .leading, endPoint: .trailing))
                }
                
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
                            NoDataView()
                        }
                    } else {
                        if !viewModel.recordCells.isEmpty {
                            ForEach(viewModel.recordCells, id: \.id) { recordCell in
                                RecordCardView(recordCell: recordCell).id(recordCell.id)
                                .listRowInsets(EdgeInsets())
                            }
                        } else {
                            NoDataView()
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .padding(.top, 6)
                .padding(.bottom, show ? headerHeight + 90: 0)
                .frame(maxWidth: width, maxHeight: contentHeight, alignment: .top)
                .background(Color("backGround"))
                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                .myShadow(radius: 10, x: 5, y: -5)
                .offset(y: show ? headerHeight : 0)
                .opacity(show ? 1 : 0)
                .zIndex(show ? 1 : 0)
            
                GeometryReader { geometry in
                    VStack {
                        //戻る矢印
                        if show {
                        HStack {
                            Image(systemName: "arrow.backward")
                                .font(.title)
                                .foregroundColor(.white)
                                .onTapGesture { self.onClickBackward() }
                            Spacer()
                        }}
                        //収支
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
                        .onTapGesture { onClickBalance() }
                        
                        // 支出と収入
                        if show && viewModel.category == nil {
                            Rectangle().foregroundColor(.white.opacity(0.5)).frame(height: 1)
                            HStack (spacing: 20) {
                                VStack (spacing: 4) {
                                    Text("支出").style(.callout, weight: .regular, color: .white)
                                    Text("\(viewModel.spending)円").style(.title3, color: .white)
                                }
                                .padding(12)
                                .background(Color.secondary.opacity(viewModel.recordType == .expense ? 0.2 : 0))
                                .cornerRadius(5)
                                .onTapGesture {
                                    viewModel.onChangeRecordType(recordType: .expense)
                                }
                                
                                VStack (spacing: 6) {
                                    Text("収入").style(.callout, weight: .regular, color: .white)
                                    Text("\(viewModel.income)円").style(.title3, color: .white)
                                }
                                .padding(12)
                                .background(Color.secondary.opacity(viewModel.recordType == .income ? 0.2 : 0))
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
//                .background(LinearGradient(gradient: Gradient(colors: [Color("themeDark").opacity(show ? 1 : 0), Color("themeLight").opacity(show ? 1 : 0)]), startPoint: .leading, endPoint: .trailing))
                .frame(maxWidth: width, maxHeight: headerHeight)
                .ignoresSafeArea(.all)
                .onTapGesture {
                    if !self.show {
                        self.open()
                    }
                }
            }
        }
        .frame(height: contentHeight)
        .animation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0))
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
//        let devices = ["iPhone 12", "iPhone 8 Plus", "iPad Air(4th generation)"]
        let devices = ["iPhone 12", "iPhone 8"]
        ForEach(devices, id: \.self) { device in
            BalanceView(height: 80, viewModel: BalanceViewModel(env: StatusObject()))
                       .previewDevice(.init(rawValue: device))
                        .environment(\.locale, Locale(identifier: "ja_JP"))
        }
    }
}
