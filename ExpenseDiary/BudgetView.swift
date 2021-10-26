//
//  BudgetView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/24.
//

import SwiftUI


struct BudgetView: View {
    let screen = UIScreen.main.bounds
    @EnvironmentObject var env: StatusObject
    @ObservedObject var viewModel: BudgetViewModel
    @Binding var show: Bool
    
    init(viewModel: BudgetViewModel, show: Binding<Bool>) {
        self.viewModel = viewModel
        self._show = show
    }
    
    var body: some View {
        Group {
            if let budgetCell = viewModel.activeBudget {
                BudgetCardView(budgetCell: budgetCell, show: $show, viewModel: BudgetViewModel(env: env))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack (alignment: .center) {
                        ForEach(viewModel.budgetCells, id: \.id) { budgetCell in
                            BudgetCardView(budgetCell: budgetCell, show: $show, viewModel: BudgetViewModel(env: env))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
            }
        }
    }
}

struct BudgetCardView: View {
    @ObservedObject var viewModel: BudgetViewModel
    let screen = UIScreen.main.bounds
    let budgetCell: BudgetCell
    
    @Binding var show: Bool
    @State var showRing = false
    
    @State var active = false
    
    @State var activeView: CGSize = .zero
    
    init(budgetCell: BudgetCell, show: Binding<Bool>, viewModel: BudgetViewModel) {
        self.budgetCell = budgetCell
        self._show = show
        self.viewModel = viewModel
    }
    
    private func close() {
        self.viewModel.activeBudget = nil
        self.show = false
    }
    
    var scale: CGFloat {
        self.show ? 2.2 : 1.0
    }
    
    var headerHeight: CGFloat {
        self.show ? self.screen.height * 0.18 * scale : self.screen.height * 0.15
    }
    
    var contentHeight: CGFloat {
        self.show ? screen.height : headerHeight
    }
    
    var pad: CGFloat {
        self.show ? self.headerHeight * 0.12 : self.headerHeight * 0.14
    }
    
    var width: CGFloat {
        self.show ? .infinity : screen.width * 0.3
    }
    var body: some View {
        ZStack (alignment: .top) {
            List {
                if viewModel.viewState == .select {
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
            .padding(.top, 20)
            .frame(maxWidth: width, maxHeight: contentHeight, alignment: .top)
            .background(Color.backGround)
            .offset(y: show ? headerHeight : 0)
            .padding(.bottom, headerHeight)
            .opacity(active && show ? 1 : 0)
            
            VStack {
                if show {
                    HStack (spacing: 3) {
                        Spacer()
                        Image(systemName: "xmark")
                            .font(.system(size: 24, weight: .light))
                            .foregroundColor(.text)
                            .offset(x: pad * 0.8 * (1 - 1/scale))
                            .opacity(show ? 1 : 0)
                            .onTapGesture {
                                    self.close()
                            }
                    }
                }
                Spacer()
                HStack (spacing: 16){
                    let spending = viewModel.getSpending(budgetCell: budgetCell)
                    let amount   = budgetCell.amount
                    let percent  = CGFloat(spending) / CGFloat(amount) * 100
                    let diff     = amount - spending
                    VStack (spacing: 10) {
                        RingView(color1: budgetCell.category.color1.opacity(0.7), color2: budgetCell.category.color2.opacity(0.7),
                                 icon: budgetCell.category.icon,
                                 size: show ? headerHeight * 0.3 : headerHeight * 0.55,
                             percent: percent, show: $showRing)
                        if show {
                            VStack (alignment: .center, spacing: 16) {
                                Text("\(budgetCell.category.name)").planeStyle(size: 16)
                                Text("\(spending)円 / \(budgetCell.amount)円").planeStyle(size: 20)
                            }
                        }
                    }

                    if !show {
                        VStack (alignment: .leading, spacing: 0) {
                            Text("\(diff >= 0 ? "残り予算" : "予算超過")").planeStyle(size: 12)
                            Text("\(abs(diff))円").planeStyle(size: 16)
                        }
                    }
                }
                Spacer()
            }
            .padding(.top, show ? 60 : pad)
            .padding(.bottom, pad)
            .padding(.horizontal, pad)
            .frame(minWidth: show ? 0 : width)
            .frame(maxHeight: headerHeight)
            .background(Color.backGround)
            .shadow(color: .dropShadow.opacity(0.1), radius: 8, x: 0, y: 0)
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
                    if self.activeView.height > 80 {
                        self.close()
                    }
                    self.activeView = .zero
                }
            )
            .onTapGesture {
                if !show {
                    self.show = true
                    self.viewModel.activeBudget = budgetCell
                }
            }
        }
        .frame(height: contentHeight)
        .background(Color.backGround)
        //.animation(.easeIn)
        .ignoresSafeArea(.all)
        .onAppear() {
            if let activeCell = self.viewModel.activeBudget, activeCell.id == budgetCell.id {
                self.active = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.showRing = true
            }
        }
    }
}

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetView(viewModel: BudgetViewModel(env: StatusObject()), show: .constant(true))
    }
}
