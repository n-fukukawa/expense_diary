//
//  AnalysisView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/24.
//

import SwiftUI
import Charts

struct AnalysisView: View {
    let heightRate: CGFloat = 0.40
    let screen = UIScreen.main.bounds
    @Binding var show: Bool
    @ObservedObject var viewModel: AnalysisViewModel
    @State var categoryPicker = false
    
    @State var activeView: CGSize = .zero
    
    var name: String {
        if self.viewModel.viewState == .category {
            return viewModel.category!.name
        } else {
            return viewModel.recordType.name + "合計"
        }
    }
    
    var colorSet: ColorSet {
        if self.viewModel.viewState == .category {
            return viewModel.category!.colorSet
        } else {
            return viewModel.recordType.colorSet
        }
    }

    
    var scale: CGFloat {
        self.show ? 1.4 : 1.0
    }
    
    var headerHeight: CGFloat {
        self.show ? self.screen.height * heightRate * scale : self.screen.height * heightRate
    }
    
    var contentHeight: CGFloat {
        self.show ? screen.height : self.screen.height * heightRate
    }
    
    var pad: CGFloat {
        self.headerHeight * 0.06
    }
    
    var width: CGFloat {
        self.show ? .infinity : self.screen.width - 40
    }
    
    func open() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9, blendDuration: 0.5)) {
            self.categoryPicker = false
            self.show = true
        }
    }
    
    func close() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9, blendDuration: 0.5)) {
            self.categoryPicker = false
            self.show = false
        }
    }

    var body: some View {
        ZStack (alignment: .top) {
            List {
                ForEach(viewModel.monthlyAmounts, id: \.key.id) { s in
                    MonthlyCardView(yearMonth: s.key, amount: s.value)
                    .listRowInsets(EdgeInsets())
                }
            }
            .listStyle(PlainListStyle())
            .padding(.top, 28)
            .padding(.bottom, show ? headerHeight + 70 : headerHeight) // padding for admob_banner
            .frame(maxHeight: contentHeight, alignment: .top)
            .offset(y: show ? headerHeight : 0)
            
            GeometryReader { geometry in
                ZStack (alignment: .top) {
                    ScrollViewReader { scrollProxy in
                        VStack {
                            HStack (spacing: 6) {
                                Group {
                                    Text(name).planeStyle(size: show ? 18 : 14)
                                    Image(systemName: "chevron.down")
                                        .rotationEffect(Angle(degrees: categoryPicker ? 180 : 0))
                                        .font(.system(size: 12 * scale, weight: .medium))
                                        .foregroundColor(.text.opacity(0.8))
                                        .padding(.trailing, 40)
                                        .padding(.vertical, 6)
                                        .offset(y: 1)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    self.categoryPicker.toggle()
                                }

                                Spacer()
                                Image(systemName: "xmark")
                                    .font(.system(size: 24, weight: .light))
                                    .foregroundColor(.text)
                                    .opacity(show ? 1 : 0)
                                    .onTapGesture { self.close() }
                            }
                            
                            if categoryPicker {
                                ScrollView (.horizontal, showsIndicators: false) {
                                    HStack (spacing: 30) {
                                        ForEach(RecordType.all(), id: \.self) { recordType in
                                            let active = self.viewModel.viewState == .total && self.viewModel.recordType == recordType
                                            VStack(spacing: 0) {
                                                Text("\(recordType.name)").customStyle(size: 12)
                                                Text("合計").customStyle(size: 12)
                                                }
                                            .frame(width: 28, height: 28)
                                            .foregroundColor(active ? recordType.color1 : .nonActive)
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
                                                .foregroundColor(active ? category.color1 : .nonActive)
                                                .id(category.id)
                                                .onTapGesture {
                                                    viewModel.onChangeCategory(category: category)
                                                    self.categoryPicker = false
                                                }
                                        }
                                    }
                                    .padding(pad * 0.5)
                                    
                                }
                            }
                        }
                        .padding(.top, show ? 60 : pad)
                        .padding(.bottom, pad)
                        .padding(.horizontal, pad)
                        .background(Color.backGround)
                        .shadow(color: .dropShadow.opacity(categoryPicker ? 0.1 : 0), radius: 10, x: 0, y: 5)
                    }
                    .zIndex(1)
                    
                    VStack (alignment: .leading, spacing: 0) {
                        ChartView(dataSet: viewModel.monthlyAmounts.reversed(), colorSet: colorSet, preview: show)
                            .padding(.leading, show ? 0 : 10)
                    }
                    .padding(.top, show ? 130 : 60) // カテゴリー選択のプルダウンの高さ分
                    .padding(.horizontal, pad)
                }
                .padding(.bottom, pad)
                .frame(maxWidth: width, maxHeight: headerHeight)
                .background(Color.backGround)
                .clipped()
                .shadow(color: .dropShadow.opacity(0.1), radius: 10, x: 5, y: 5)
                .padding(.bottom, 12)
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
                })
                .onTapGesture {
                    if !self.show {
                        self.open()
                    }
                }
            }
        }
        .frame(height: contentHeight)
        .ignoresSafeArea(.all)
    }
}
