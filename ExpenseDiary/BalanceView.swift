//
//  BalanceView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/23.
//

import SwiftUI

struct BalanceView: View {
    @EnvironmentObject var env: StatusObject
    @ObservedObject var viewModel: BalanceCardViewModel
    let screen = UIScreen.main.bounds
    @Binding var show: Bool
    @State var activeView: CGSize = .zero
    
    let firstRecordCellId: String?
    
    var scale: CGFloat {
        self.show ? 1.8 : 1.0
    }
    
    var headerHeight: CGFloat {
        self.show ? self.screen.height * 0.18 * scale : self.screen.height * 0.18
    }
    
    var contentHeight: CGFloat {
        self.show ? screen.height : headerHeight
    }
    
    var pad: CGFloat {
        self.headerHeight * 0.13
    }
    
    var width: CGFloat {
        self.show ? .infinity : self.screen.width - 40
    }
    
    let formatter = DateFormatter()
    
    init(show: Binding<Bool>, viewModel: BalanceCardViewModel) {
        self._show = show
        self.viewModel = viewModel
        self.firstRecordCellId = viewModel.diary.first?.id
        
        formatter.dateFormat = "M.d"
    }
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ZStack (alignment: .top) {
                List {
                    ForEach(viewModel.diary, id: \.id) { recordCell in
                        RecordCardView(recordCell: recordCell).id(recordCell.id)
                        .listRowInsets(EdgeInsets())
                    }
                }
                .listStyle(PlainListStyle())
                .padding(.top, 20)
                .frame(maxWidth: width, maxHeight: contentHeight, alignment: .top)
                .background(Color.backGround)
                .offset(y: show ? headerHeight : 0)
                .padding(.bottom, headerHeight)
                .opacity(show ? 1 : 0)
            
            VStack {
                HStack {
                    VStack (alignment: .leading, spacing: 0) {
                        HStack(spacing: 3) {
                            if !show {
                                Text("\(formatter.string(from: env.startDate))").planeStyle(size: 13, tracking: 1)
                                Text("-").subStyle(size: 12, tracking: 1)
                                Text("\(formatter.string(from: env.endDate))").planeStyle(size: 13, tracking: 1)
                            }
                            Spacer()
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 24, weight: .light))
                                .foregroundColor(.text)
                                .offset(x: pad * (1 - 1/scale))
                                .opacity(show ? 1 : 0)
                                    .onTapGesture {
                                        if let id = self.firstRecordCellId {
                                            scrollProxy.scrollTo(id)
                                        }
                                        self.show = false
                                    }
                        }
                    }
                    Spacer()
                }
                
                Spacer()

                HStack {
                    VStack (alignment: .leading, spacing: 4) {
                        Text("+36,821円").planeStyle(size: show ? 28 : 24, tracking: 3)
                            .offset(x: show ? -4 : 0)
                    }
                    if !show {
                        Spacer()
                    }
                }
                if show {
                    Divider()
                    Spacer()
                    HStack {
                        Spacer()
                        VStack (spacing: 4) {
                            Text("支出").planeStyle(size: 13)
                            Text("119,682円").planeStyle(size: 18)
                        }
                        Spacer()
                        VStack (spacing: 6) {
                            Text("収入").planeStyle(size: 13)
                            Text("163,564円").planeStyle(size: 18)
                        }
                        Spacer()
                    }
                    //.offset(x: show ? 0 : -screen.width)
                    .opacity(show ? 1 : 0)
                    //.animation(.easeIn)
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
                        if let id = self.firstRecordCellId {
                            scrollProxy.scrollTo(id)
                        }
                        self.activeView = .zero
                        self.show = false
                    }
                }
                .onEnded { value in
                    if !show { return }
                    if self.activeView.height > 80 {
                        if let id = self.firstRecordCellId {
                            scrollProxy.scrollTo(id)
                        }
                        self.show = false
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
        .animation(.spring(response: 0.5, dampingFraction: 0.75, blendDuration: 0.5))
        .ignoresSafeArea(.all)
    }
}
