//
//  BalanceView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/23.
//

import SwiftUI

struct BalanceView: View {
    let heightRate: CGFloat = 0.18
    let screen = UIScreen.main.bounds
    @EnvironmentObject var env: StatusObject
    @ObservedObject var viewModel: BalanceViewModel
    @Binding var show: Bool
    @State var activeView: CGSize = .zero
    
    var scale: CGFloat {
        self.show ? (self.viewModel.viewState != .category ? 1.8 : 1.4) : 1.0
    }
    
    var headerHeight: CGFloat {
        self.show ? self.screen.height * heightRate * scale : self.screen.height * heightRate
    }
    
    var contentHeight: CGFloat {
        self.show ? screen.height : headerHeight
    }
    
    var pad: CGFloat {
        self.headerHeight * 0.12
    }
    
    var width: CGFloat {
        self.show ? .infinity : self.screen.width - 40
    }
    
    let formatter = DateFormatter()
    
    init(show: Binding<Bool>, viewModel: BalanceViewModel) {
        self._show = show
        self.viewModel = viewModel
        
        formatter.dateFormat = "M-d"
    }
    
    func close() {
        self.viewModel.onChangeCategory(category: nil)
        self.viewModel.onChangeRecordType(recordType: nil)
        self.show = false
    }
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ZStack (alignment: .top) {
                List {
                    if viewModel.viewState == .summary {
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
                        ForEach(viewModel.recordCells, id: \.id) { recordCell in
                            RecordCardView(recordCell: recordCell).id(recordCell.id)
                            .listRowInsets(EdgeInsets())
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .padding(.top, 20)
                .frame(maxWidth: width, maxHeight: contentHeight, alignment: .top)
                .background(Color.backGround)
                .offset(y: show ? headerHeight : 0)
                .padding(.bottom, show ? headerHeight + 70 : headerHeight) // padding for admob_banner
                .opacity(show ? 1 : 0)
            
                VStack {
                    HStack {
                        VStack (alignment: .leading, spacing: 0) {
                            HStack(spacing: 3) {
                                if viewModel.viewState == .category {
                                    Image(systemName: "arrow.backward")
                                        .font(.system(size: 24, weight: .light))
                                        .foregroundColor(.text)
                                        .opacity(show ? 1 : 0)
                                        .onTapGesture {
                                            viewModel.onChangeCategory(category: nil)
                                        }
                                }
  
                                // 開始日と終了日
                                if !show {
                                    Text("\(formatter.string(from: env.startDate))").planeStyle(size: 13, tracking: 1)
                                    Text("→").planeStyle(size: 12, tracking: 1)
                                    Text("\(formatter.string(from: env.endDate))").planeStyle(size: 13, tracking: 1)
                                }
                                Spacer()
                                
                                Image(systemName: "xmark")
                                    .font(.system(size: 24, weight: .light))
                                    .foregroundColor(.text)
                                    .offset(x: pad * (1 - 1/scale))
                                    .opacity(show ? 1 : 0)
                                    .onTapGesture { self.close() }
                            }
                        }
                        Spacer()
                    }
                    
                    Spacer()

                    HStack {
                        VStack (alignment: .leading, spacing: 0) {
                            if viewModel.viewState == .category {
                                Text(viewModel.category!.name).planeStyle(size: 16)
                                    .offset(x: -pad * (1 - 1/scale))
                            }

                            Text(viewModel.viewState == .category
                                    ? "\(viewModel.categoryAmount)円"
                                    : "\(viewModel.balance > 0 ? "+" : (viewModel.balance < 0 ? "−" : ""))\(abs(viewModel.balance))円")
                                .planeStyle(size: show ? 28 : 24, tracking: 3)
                                .offset(x: show ? -4 : 0)
                        }
                        .onTapGesture {
                            if show {
                                viewModel.onChangeRecordType(recordType: nil)
                            } else {
                                self.show = true
                            }
                        }
                        if !show {
                            Spacer()
                        }
                    }
                    if viewModel.category != nil {
                        Spacer()
                    }
                    if show && viewModel.category == nil {
                        Divider()
                        Spacer()
                        HStack {
                            Spacer()
                            VStack (spacing: 4) {
                                Text("支出").planeStyle(size: 13)
                                Text("\(viewModel.spending)円").planeStyle(size: 18)
                            }
                            .padding(8)
                            .background(Color.nonActive.opacity(viewModel.recordType == .expense ? 0.2 : 0))
                            .cornerRadius(5)
                            .onTapGesture {
                                viewModel.onChangeRecordType(recordType: .expense)
                            }
                            
                            Spacer()
                            
                            VStack (spacing: 6) {
                                Text("収入").planeStyle(size: 13)
                                Text("\(viewModel.income)円").planeStyle(size: 18)
                            }
                            .padding(8)
                            .background(Color.nonActive.opacity(viewModel.recordType == .income ? 0.2 : 0))
                            .cornerRadius(5)
                            .onTapGesture {
                                viewModel.onChangeRecordType(recordType: .income)
                            }
                            Spacer()
                        }
                        .opacity(show ? 1 : 0)
                    }
                }
                .padding(.top, show ? 60 : pad)
                .padding(.bottom, pad)
                .padding(.horizontal, pad)
                .frame(maxWidth: width, maxHeight: headerHeight)
                .background(Color.backGround)
                .shadow(color: .dropShadow.opacity(show ? 0.05 : 0.1), radius: 8, x: 0, y: 4)
                .gesture(
                    DragGesture()
                    .onChanged { value in
                        if !show { return }
                        self.activeView = value.translation
                        if self.activeView.height > 200 {
                            self.activeView = .zero
                            self.close()
                        }
                    }
                    .onEnded { value in
                        if !show { return }
                        if self.activeView.height > 50 {
                            self.close()
                        }
                        self.activeView = .zero
                    }
                )
                .onTapGesture {
                    if !self.show {
                        self.show = true
                    }
                }
            }
        }
        .frame(height: contentHeight)
        .scaleEffect(1 - activeView.height / 1000)
        .animation(.spring(response: 0.4, dampingFraction: 0.9, blendDuration: 0.5))
        .ignoresSafeArea(.all)
        .gesture(
            DragGesture()
                .onChanged { _ in }
                .onEnded { value in
                    if value.translation.width > 50 {
                        if viewModel.category == nil {
                            self.close()
                        } else {
                            viewModel.onChangeCategory(category: nil)
                        }
                    }
                }
        )
    }
}
