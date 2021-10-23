//
//  ContentView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import SwiftUI
import RealmSwift

struct RootView: View {
    let screen = UIScreen.main.bounds
    let formatter = DateFormatter()
    
    @EnvironmentObject var env: StatusObject
    @State var showSettingMenu = false
    @State var showPicker = false
    @State var contentType: ContentType = .records
    @State var showRing = false
    
    @State var showBalance = false
    @State var showBadget = false
    
    @State var lineChartRender: CGFloat = 0
    
    let BALANCE_VIEW_HEIGHT: CGFloat = 0.18
    
    var showModal: Bool {
        self.showSettingMenu || self.showPicker
    }
    
    init() {
        let realm = try! Realm()

        try! realm.write {
             realm.deleteAll()
        }
        Icon.seed()
        Theme.seed()
        ColorSet.seed()

        Category.seed()
        Budget.seed()
        Record.seed()
    }

    var body: some View {
        let multiplier = screen.height / 844
        let cardInPadding: CGFloat = 20
        
        NavigationView {
            ZStack {
                Color.backGround.ignoresSafeArea(.all)
                
                VStack (spacing: 0) {
                    HeaderView(showSettingMenu: $showSettingMenu, showPicker: $showPicker)
                        .padding(.horizontal, 30)
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                    
                    GeometryReader { geometry in
                        BalanceView(show: self.$showBalance, viewModel: BalanceCardViewModel(env: env))
                            .offset(y: self.showBalance ? -geometry.frame(in: .global).minY : 0)
                            
                    }
                    .frame(maxWidth: showBalance ? .infinity : screen.width - 40)
                    .frame(height: screen.height * 0.18)
                    .zIndex(showBalance ? 1 : 0)
                    
                    GeometryReader { geometry in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack (alignment: .center) {
                                ForEach(Budget.all(), id: \.self) { budget in
                                    BudgetCardView(budget: budget, height: screen.height * 0.15, padding: cardInPadding)
                                        .onTapGesture {
                                            self.showBadget.toggle()
                                        }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .offset(y: self.showBadget ? -geometry.frame(in: .global).minY : 0)
                        }
                    }
                    .frame(height: self.showBadget ? screen.height : screen.height * 0.18)
                    .zIndex(showBadget ? 1 : 0)
                    //.frame(maxWidth: showBalance ? .infinity : screen.width - 40)
                    
                    VStack {
                        Spacer()
                        HStack {
                            VStack (alignment: .leading, spacing: 0) {
                                HStack (spacing: 6) {
                                    Image(Icon.all()[6].name)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 28 * multiplier)
                                        .foregroundColor(.nonActive)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12 * multiplier, weight: .medium))
                                        .foregroundColor(.text)
                                        .opacity(0.8)
                                        .offset(y: 1)
                                }
                                ChartView(preview: true).padding(.leading, 10)
                                    .onAppear() {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                            withAnimation(.linear(duration: 3.0)) {
                                                lineChartRender = 1.0
                                            }
                                        }
                                    }
                            }
                            Spacer()
                        }
                    }
                    .padding(cardInPadding)
                    //.frame(height: screen.height * 0.25)
                    .background(Color.backGround)
                    .clipped()
                    .shadow(color: .dropShadow.opacity(0.1), radius: 10, x: 5, y: 5)
                    .padding(.bottom, 12)
                    
                    AdmobBannerView().frame(width: 320, height: 50)
                        .padding(.bottom, 4)
                }
                
                
//                ZStack {
//                    Color.black.opacity(self.showModal ? 0.1 : 0).ignoresSafeArea(.all)
//                }
//                .onTapGesture {
//                    withAnimation {
//                        self.showSettingMenu = false
//                        self.showPicker = false
//                    }
//                }

                SettingMenuView(isActive: $showSettingMenu).transition(.slide)
                
//                if showPicker {
//                    VStack {
//                        Text("a").padding()
//                    }.modifier(ModalCardModifier(active: showPicker))
//                }
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


struct HeaderView: View {
    @EnvironmentObject var env: StatusObject
    @Binding var showSettingMenu: Bool
    @Binding var showPicker: Bool
    let formatter = DateFormatter()
    
    init(showSettingMenu: Binding<Bool>, showPicker: Binding<Bool>) {
        self._showSettingMenu = showSettingMenu
        self._showPicker = showPicker
        formatter.dateFormat = "M/d"
    }
    var body: some View {
        VStack {
            HStack {
                Button(action: { withAnimation() {
                    self.showSettingMenu = true
                }}){
                    VStack (alignment: .leading, spacing: 8) {
                        ForEach(0..<2) { i in
                            Rectangle()
                                .frame(width: 24 - CGFloat(i) * 6 , height: 1)
                                .foregroundColor(.text)
                        }
                    }
                }
                
                Spacer()
            }
            
            HStack {
                Button(action: { self.showPicker = true }) {
                    HStack {
                        Text("\(env.activeMonth)").planeStyle(size: 36)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.text)
                            .opacity(0.8)
                            .offset(y: 5)
                    }
                }
                
                Spacer()
                
                Button(action: { withAnimation() {
                    //
                }}){
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .thin))
                        .foregroundColor(.text)
                }
            }



        }
    }
}

struct RecordCardView: View {
    let recordCell: RecordCell
    let formatter = DateFormatter()
    
    init(recordCell: RecordCell) {
        self.recordCell = recordCell
        formatter.dateFormat = "M.d E"
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(formatter.string(from: recordCell.date)).planeStyle(size: 14)
                Spacer()
            }
            HStack (spacing: 20) {
                ZStack {
                    Circle().foregroundColor(.gray).opacity(0.1)
                    Image(recordCell.category.icon.name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.text).opacity(0.8)
                }
                .frame(width: 50, height: 50)
                
                VStack (alignment: .leading, spacing: 2) {
                    Text(recordCell.category.name).planeStyle(size: 18)
                    Text(recordCell.memo).planeStyle(size: 14)
                }
                Spacer()
                Text("\(recordCell.amount)円").planeStyle(size: 18)
            }
            Divider()
        }
        .padding(.bottom, 16)
        .padding(.horizontal, 32)
        .background(Color.backGround)
    }
}






struct BudgetCardView: View {
    let budget: Budget
    let height: CGFloat
    let padding: CGFloat
    @State var showRing = false
    var body: some View {
        HStack (spacing: 16){
            RingView(color1: budget.category.color1.opacity(0.7), color2: budget.category.color2.opacity(0.7),
                     icon: budget.category.icon, size: height * 0.6, percent: 80, show: $showRing)
            VStack (alignment: .leading, spacing: 0) {
                Text("残り").planeStyle(size: 12)
                Text("3,800円").planeStyle(size: 18)
            }
        }
        .padding(padding)
        .frame(height: height)
        .background(Color.backGround)
        .shadow(color: .dropShadow.opacity(0.1), radius: 8, x: 0, y: 0)
    }
}

//struct TabView: View {
//    @Binding var contentType: ContentType
//    var body: some View {
//        HStack(spacing: 0) {
//            ForEach(ContentType.all(), id: \.self) { contentType in
//                let is_active = self.contentType == contentType
//                Button(action: {
//                    self.contentType = contentType
//                }){
//                    VStack(spacing: 4) {
//                        Text(contentType.rawValue)
//                            .subStyle(size: is_active ? 20 : 16, tracking: 1)
//                        RoundedRectangle(cornerRadius: 10)
//                            .frame(width: 20, height: 2)
//                            .opacity(is_active ? 1 : 0)
//                            .foregroundColor(.sub)
//                    }
//                    .frame(height: 46)
//                    .frame(maxWidth: .infinity)
//                }
//            }
//        }
//    }
//}

//struct MainView: View {
//    @Binding var contentType: ContentType
//    var body: some View {
//        ZStack {
////            Rectangle()
////                .cornerRadius(25.0, corners: [.topLeft, .topRight])
////                .foregroundColor(.neuBackGround)
////                .ignoresSafeArea(edges: .bottom)
//
//            VStack {
////                 ContentView(type: $contentType)
////                    .padding(.horizontal, 16)
////                    .padding(.top, 24)
////                    .padding(.bottom, 20)
//                 Spacer()
//                 AdmobBannerView().frame(width: 320, height: 50)
//            }
//        }
//
//    }
//}

//struct ContentView: View {
//    @EnvironmentObject var env: StatusObject
//    @Binding var type: ContentType
//    
//    var body: some View {
//        switch (type) {
//            case .records  : ListView(env: env)
//            case .summary  : SummaryView(env: env)
//            case .chart    : ChartView()
//        }
//    }
//}

//struct GlobalNavView: View {
//    @EnvironmentObject var env: StatusObject
//    @State var isShowing = false
//    var body: some View {
//        ZStack {
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        self.isShowing = true
//                    }){
//                        ZStack {
//                            Circle().foregroundColor(.sub)
//                                .shadow(color: .sub.opacity(0.5), radius: 6, x: 2, y: 2)
//                            Image(systemName: "plus")
//                                .font(.system(size: 22, weight: .bold))
//                                .foregroundColor(.white)
//                        }
//                        .frame(width: 56, height: 56)
//                    }
//                    .sheet(isPresented: $isShowing) {
//                        EditRecordView()
//                    }
//                }
//            }
//        }
//    }
//}



struct NoDataView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("データがありません").planeStyle(size: 16)
            Spacer()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
//        let devices = ["iPhone 12", "iPhone 8 Plus", "iPad Air(4th generation)"]
        let devices = ["iPhone 12", "iPhone 8", "iPad (8th generation)"]
        ForEach(devices, id: \.self) { device in
            RootView().environmentObject(StatusObject())
                       .previewDevice(.init(rawValue: device))
                        .environment(\.locale, Locale(identifier: "ja_JP"))
        }
    }
}
