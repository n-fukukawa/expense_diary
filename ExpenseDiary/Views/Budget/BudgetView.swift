//
//  BudgetView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/24.
//

import SwiftUI


struct BudgetView: View {
    let width: CGFloat = 220
    let height: CGFloat = 80
    let screen = UIScreen.main.bounds
    @EnvironmentObject var env: StatusObject
    @ObservedObject var viewModel: BudgetViewModel
    @State var activeBudgetCell: BudgetCell?
    
    init(viewModel: BudgetViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
            if let activeCell = self.activeBudgetCell {
                BudgetCardView(budgetCell: activeCell,
                                   active: true,
                                   activeBudgetCell: $activeBudgetCell,
                                   viewModel: BudgetViewModel(env: env))
                    .opacity(env.viewType == .budget ? 1 : 0)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 20) {
                    ForEach(viewModel.budgetCells, id: \.id) { BudgetCell in
                        BudgetCardView(budgetCell: BudgetCell,
                                       active: false,
                                       activeBudgetCell: $activeBudgetCell,
                                       viewModel: BudgetViewModel(env: env))
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 20)
            }
            .opacity(env.viewType == .budget ? 0 : 1)
    }
}

struct BudgetCardView: View {
    let height: CGFloat = 80
    let width: CGFloat = 220
    @EnvironmentObject var env: StatusObject
    @ObservedObject var viewModel: BudgetViewModel
    @Binding var activeBudgetCell: BudgetCell?
    let screen = UIScreen.main.bounds
    let budgetCell: BudgetCell
    
    let active: Bool
    let formatter = DateFormatter()
    
    @State var showRing = false
    
    var scale: CGFloat {
        self.active ? 3.2: 1.0
    }
    
    init(budgetCell: BudgetCell, active: Bool, activeBudgetCell: Binding<BudgetCell?>, viewModel: BudgetViewModel) {
        self.budgetCell = budgetCell
        self.active = active
        self._activeBudgetCell = activeBudgetCell
        self.viewModel = viewModel
        
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日(E)"
    }
    
    private func open() {
        self.activeBudgetCell = budgetCell
        self.viewModel.onSelectBudget(budgetCell: budgetCell)
        withAnimation() {
            self.env.onChangeViewType(.budget)
        }
//        self.env.showYearMonthPicker = false
    }
    
    private func close() {
        self.activeBudgetCell = nil
        self.viewModel.activeBudget = nil
        withAnimation(.easeInOut(duration: 0.6)) {
            self.env.viewType = .home
        }

    }
    
    var body: some View {
        ZStack (alignment: .top) {
            if active {
                Color("backGround").ignoresSafeArea(.all)
//            Rectangle().fill(LinearGradient(gradient: Gradient(colors: [Color("themeDark").opacity(active ? 1 : 0), Color("themeLight").opacity(active ? 1 : 0)]), startPoint: .leading, endPoint: .trailing))
            }
            
            List {
                if !viewModel.recordCells.isEmpty {
                    if let recordCells = viewModel.recordCells[budgetCell] {
                        ForEach(recordCells, id: \.key) { date, recordCells in
                            Section (header: RecordSectionHeaderView(date: date, recordCells: recordCells)) {
                                ForEach(recordCells) { recordCell in
                                    RecordCardView(recordCell: recordCell).id(recordCell.id)
                                    .listRowInsets(EdgeInsets())
                                }
                            }
                        }
                    } else {
                        NoDataView()
                    }
                }
            }
            .listStyle(PlainListStyle())
            .padding(.bottom, height * scale + 60 + 120)
            .frame(width: active ? screen.width : width)
            .frame(height: active ? screen.height : height, alignment: .top)
            
            .background(Color("backGround"))
//            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
//            .myShadow(radius: 10, x: 1, y: -1)
            .offset(y: active ? height * scale + 60 : 0)
            .padding(.top, 20)
            .opacity(active ? 1 : 0)
            
            
            GeometryReader { geometry in
                let spending = viewModel.getSpending(budgetCell: budgetCell)
                let amount   = budgetCell.amount
                let percent  = CGFloat(spending) / CGFloat(amount) * 100
                let diff     = amount - spending
                VStack {
                    if active {
                        Spacer()
                        HStack (spacing: 3) {
                            Image(systemName: "arrow.backward")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(Color("secondary"))
                                .opacity(active ? 1 : 0)
                                .onTapGesture {
                                    self.close()
                                }
                            Spacer()
                        }
                        .padding(.leading, 10)
                            VStack (spacing: 8) {
                                RingView(icon: budgetCell.category.icon,size: active ?  height * 1.2 : height * 0.8,
                                         percent: percent, show: $showRing)
                                Text("\(budgetCell.category.name)")
                                    .style(weight: .semibold)
                                    .padding(.bottom, 8)
                                HStack {
                                    Text("\(spending) / \(amount)円").style(.title2)
                                }
                            }
                        Spacer()
                    } else {
                        Button(action: {
                        if !active {
                            self.open()
                        }})
                        {
                            VStack (spacing: 0) {
                                VStack (spacing: 0) {
                                    Spacer()
                                    HStack (spacing: 16) {
                                        RingView(icon: budgetCell.category.icon,size: active ?  height * 1.2 : height * 0.8,
                                                 percent: percent, show: $showRing)
                                        VStack {
                                            VStack (alignment: .leading, spacing: 0) {
                                                if diff >= 0 {
                                                    Text("残り予算").style(.caption2, tracking: 0)
                                                    Text("\(diff)円").style(.body, tracking: 1)
                                                } else {
                                                    Text("予算オーバー").style(.caption2, tracking: 0, color: Color("warningLight"))
                                                    Text("+\(abs(diff))円").style(.body, tracking: 1, color: Color("warningLight"))
                                                }
                                            }
                                        }
                                        Spacer()
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            .frame(width: active ? screen.width - 40 : width)
            .frame(height: height * scale)
            .background(Color("backGround"))
            .cornerRadius(active ? 0 : 10)
            .padding(.top, active ? 60 : 0)
            //.cornerRadius(active ? 0 : height / 2)
            .clipped()
            .shadow(color: .primary.opacity(active ? 0.3 : 0.2), radius: active ? 12 : 10, x: 0, y: 0)
            .onTapGesture {

            }
        }
        
       // .animation(.spring(response: 0.5, dampiprintngFraction: 0.8, blendDuration: 0))
        .ignoresSafeArea(.all)
        .gesture(
            DragGesture().onEnded(){ value in
                if active && value.translation.width > 50 {
                    self.close()
                }
            }
        )
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.showRing = true
            }
        }
        .onDisappear() {
            self.showRing = false
        }
    }
}

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetView(viewModel: BudgetViewModel(env: StatusObject()))
    }
}
