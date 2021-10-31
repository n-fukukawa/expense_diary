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
    
    var name: String {
        if self.viewModel.viewState == .category {
            return viewModel.category!.name
        } else if self.viewModel.viewState == .total {
            return viewModel.recordType!.name + "合計"
        } else {
            return "収支"
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
        VStack (spacing: 0) {
            ScrollViewReader { scrollProxy in
                VStack (spacing: 20) {
                    HStack (spacing: 6) {
                        Spacer()
                        Group {
                            Text(name).style(.title2, color: .white)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .rotationEffect(categoryPicker ? Angle(degrees: 180) : Angle(degrees: 0))
                            }
                            .onTapGesture {
                                self.categoryPicker.toggle()
                            }
                        Spacer()
                    }
                    if categoryPicker {
                        ScrollView (.horizontal, showsIndicators: false) {
                            HStack (spacing: 30) {
                                let active = self.viewModel.viewState == .balance
                                VStack(spacing: 0) {
                                    Text("収支").style(.title3, color: active ? .dangerDark : .white)
                                        .scaleEffect(0.8)
                                    }
                                .frame(height: 28)
                                .onTapGesture {
                                    self.viewModel.onClickBalance()
                                    self.categoryPicker = false
                                }
                                
                                ForEach(RecordType.all(), id: \.self) { recordType in
                                    let active = self.viewModel.viewState == .total && self.viewModel.recordType == recordType
                                    VStack(spacing: 0) {
                                        Text("\(recordType.name)").style(.title3, color: active ? .dangerDark : .white)
                                            .scaleEffect(0.8)
//                                        Text("合計").style(.caption, color: active ? .dangerDark : .white)
                                        }
                                    .frame(height: 28)
                                    .onTapGesture {
                                        viewModel.onChangeRecordType(recordType: recordType)
                                        self.categoryPicker = false
                                    }
                                }
                                
                                ForEach(Category.all(), id: \.id) { category in
                                    let active = self.viewModel.category == category
                                    Image(category.icon.name)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 28, height: 28)
                                        .foregroundColor(active ? .dangerDark : .white)
                                        .id(category.id)
                                        .onTapGesture {
                                            viewModel.onChangeCategory(category: category)
                                            self.categoryPicker = false
                                        }
                                }
                            }
                            //.padding(pad * 0.5)
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
                .padding(.top, 60)
                .padding(.bottom, 20)
                .background(Rectangle().fill(LinearGradient(gradient: Gradient(colors: [.themeDark, .themeLight]), startPoint: .leading, endPoint: .trailing)))
                .myShadow(radius: 10, x: 0, y: 5, valid: categoryPicker)
            }
            
            VStack (alignment: .leading, spacing: 0) {
                ChartView(dataSet: viewModel.monthlyAmounts.reversed(), balance: self.viewModel.viewState == .balance)
            }
            .padding(20)
            .background(Color.backGround)
            .clipped()
            .myShadow(radius: 10, x: 1, y: 1)
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
        .ignoresSafeArea(.all)
    }
}
