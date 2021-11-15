//
//  AnalysisView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/24.
//

import SwiftUI
import Charts

struct AnalysisView: View {
    let screen = UIScreen.main.bounds
    @EnvironmentObject var env: StatusObject
    @ObservedObject var viewModel: AnalysisViewModel
    @State var categoryPicker = false
    
    init(viewModel: AnalysisViewModel) {
        self.viewModel = viewModel
    }
    
    var name: String {
        if self.viewModel.viewState == .category {
            return viewModel.category!.name
        } else if self.viewModel.viewState == .total {
            return viewModel.recordType!.name + "合計"
        } else {
            return "収支"
        }
    }
    
    func closeCategoryPicker() {
        withAnimation(.easeInOut(duration: 0.4)) {
            self.categoryPicker = false
        }
    }

    func open() {
        withAnimation(.none) {
            self.categoryPicker = false
            self.env.onChangeViewType(.analysis)
        }
    }
    
    func close() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9, blendDuration: 0.5)) {
            self.categoryPicker = false
            self.env.onChangeViewType(.home)
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color("backGround").ignoresSafeArea(.all)
            Rectangle()
                .fill(LinearGradient(gradient: Gradient(colors: [Color(env.themeDark), Color(env.themeLight)]), startPoint: .leading, endPoint: .trailing))
                .frame(height: screen.height * 0.3)
                .ignoresSafeArea(.all)
            VStack (spacing: 0) {
                ScrollViewReader { scrollProxy in
                    VStack (spacing: 20) {
                        HStack (spacing: 6) {
                            Spacer()
                            Text(name).style(.title2, color: .white)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .rotationEffect(categoryPicker ? Angle(degrees: 180) : Angle(degrees: 0))
                            Spacer()
                        }
                        .offset(x: 6)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                self.categoryPicker.toggle()
                            }
                        }
                        
                        if categoryPicker {
                            ScrollView (.horizontal, showsIndicators: false) {
                                HStack (spacing: 16) {
                                    let active = self.viewModel.viewState == .balance
                                    VStack(spacing: 0) {
                                        Text("収支").style(.title3, weight: .medium, color: .white)
                                            .scaleEffect(0.8)
                                        }
                                    .padding(4)
                                    .background(Color.white.opacity(active ? 0.2 : 0))
                                    .cornerRadius(5)
                                    .onTapGesture {
                                        self.viewModel.onClickBalance()
                                        self.closeCategoryPicker()
                                    }
                                    
                                    ForEach(RecordType.all(), id: \.self) { recordType in
                                        let active = self.viewModel.viewState == .total && self.viewModel.recordType == recordType
                                        VStack(spacing: 0) {
                                            Text("\(recordType.name)").style(.title3, weight: .medium, color: .white)
                                                .scaleEffect(0.8)
                                        }
                                        .padding(4)
                                        .background(Color.white.opacity(active ? 0.2 : 0))
                                        .cornerRadius(5)
                                        .onTapGesture {
                                            viewModel.onChangeRecordType(recordType: recordType)
                                            self.closeCategoryPicker()
                                        }
                                    }
                                    
                                    ForEach(Category.all(), id: \.id) { category in
                                        let active = self.viewModel.category == category
                                        VStack {
                                            Image(category.icon.name)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 28, height: 28)
                                                .foregroundColor(.white)
                                                .id(category.id)

                                            Text("\(category.name)").style(.caption2, weight: .medium, tracking: 1, color: .white)
                                        }
                                        .frame(width: 64, height: 64)
                                        .background(Color.white.opacity(active ? 0.2 : 0))
                                        .cornerRadius(5)
                                        .onTapGesture {
                                            viewModel.onChangeCategory(category: category)
                                            self.closeCategoryPicker()
                                        }
                                    }
                                }
                                .padding(.horizontal, 30)
                            }
                            .opacity(categoryPicker ? 1 : 0)
                            .onAppear() {
                                if let category = self.viewModel.category {
                                    scrollProxy.scrollTo(category.id, anchor: .center)
                                }
                            }
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }
                VStack (alignment: .leading, spacing: 0) {
                    ChartView(dataSet: viewModel.monthlyAmounts.reversed(), balance: self.viewModel.viewState == .balance, env: env)
                }
                .padding(20)
                .background(Color("backGround"))
                .clipped()
                .myShadow(radius: 4, x: 1, y: 1)
                .frame(height: screen.height * 0.4)
                .zIndex(1)
                
                List {
                    ForEach(viewModel.monthlyAmounts, id: \.key.id) { s in
                        MonthlyCardView(yearMonth: s.key, amount: s.value)
                        .listRowInsets(EdgeInsets())
                    }
                }
                .listStyle(PlainListStyle())
                .padding(.top, 20)

                Spacer(minLength: 50 + 60 + 30)// padding for admob_banner & tabBar
            }
        }
    }
}
