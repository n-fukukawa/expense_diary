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
                let spending = viewModel.getSpending(budgetCell: activeCell)
                BudgetCardView(budgetCell: activeCell,
                                   active: true,
                                   activation: $viewModel.active,
                                   activeBudgetCell: $activeBudgetCell,
                                   recordCells: viewModel.recordCells[activeCell] ?? [],
                                   spending: spending)
                    .opacity(env.viewType == .budget ? 1 : 0)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 20) {
                    ForEach(viewModel.budgetCells, id: \.id) { budgetCell in
                        let spending = viewModel.getSpending(budgetCell: budgetCell)
                        BudgetCardView(budgetCell: budgetCell,
                                       active: false,
                                       activation: $viewModel.active,
                                       activeBudgetCell: $activeBudgetCell,
                                       recordCells: viewModel.recordCells[budgetCell] ?? [],
                                       spending: spending)
//                            .gesture(
//                                DragGesture().onEnded(){ value in
//                                    if active && value.translation.width > 50 {
//                                        self.close()
//                                    }
//                                }
//                            )
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
//    @Binding var activeBudgetCell: BudgetCell?
    let screen = UIScreen.main.bounds
    let budgetCell: BudgetCell
    
    let active: Bool
    @Binding var activation: Bool
    @Binding var activeBudgetCell: BudgetCell?
    let recordCells: [(key: Date, value: [RecordCell])]
    let spending: Int
    let formatter = DateFormatter()
    
    @State var showRing = false
    
    var scale: CGFloat {
        self.active ? 3.2: 1.0
    }
    
    init(budgetCell: BudgetCell, active: Bool, activation: Binding<Bool>, activeBudgetCell: Binding<BudgetCell?>, recordCells: [(key: Date, value: [RecordCell])], spending: Int) {
        self.budgetCell = budgetCell
        self.active = active
        self._activation = activation
        self._activeBudgetCell = activeBudgetCell
        self.recordCells = recordCells
        self.spending = spending
        
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日(E)"
    }
    
    private func open() {
        self.activation = true
        self.activeBudgetCell = self.budgetCell
        withAnimation() {
            self.env.onChangeViewType(.budget)
        }
    }
    
    private func close() {
        self.activation = false
        self.activeBudgetCell = nil
        withAnimation(.easeInOut(duration: 0.6)) {
            self.env.viewType = .home
        }
    }
    
    var body: some View {
        ZStack (alignment: .top) {
            if active {
                Color("backGround").ignoresSafeArea(.all)
            }
            if !budgetCell.category.isInvalidated {
                List {
                    if !recordCells.isEmpty {
                        ForEach(recordCells, id: \.key) { date, recordCells in
                            Section (header: RecordSectionHeaderView(date: date, recordCells: recordCells)) {
                                ForEach(recordCells) { recordCell in
                                    RecordCardView(recordCell: recordCell).id(recordCell.id)
                                    .listRowInsets(EdgeInsets())
                                }
                            }.id(UUID())
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .padding(.bottom, height * scale + 60 + 120)
                .frame(width: active ? screen.width : width)
                .frame(height: active ? screen.height : height, alignment: .top)
                
                .background(Color("backGround"))
                .offset(y: active ? height * scale + 60 : 0)
                .padding(.top, 20)
                .opacity(active ? 1 : 0)
                
                
                GeometryReader { geometry in
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
                .clipped()
                .shadow(color: .primary.opacity(active ? 0.3 : 0.2), radius: active ? 12 : 10, x: 0, y: 0)
            }

        }
        .ignoresSafeArea(.all)
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
