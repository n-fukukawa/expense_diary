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
    @State var showBadget  = false
    @State var showAnalysis   = false
    
    @State var lineChartRender: CGFloat = 0
    
    var showModal: Bool {
        self.showSettingMenu || self.showPicker
    }
    
    init() {
//        let realm = try! Realm()
//
//        try! realm.write {
//             realm.deleteAll()
//        }
//        Icon.seed()
//        Theme.seed()
//        ColorSet.seed()
//
//        Category.seed()
//        Budget.seed()
        //Record.seed()
    }

    var body: some View {
        
        NavigationView {
            ZStack {
                Color.backGround.ignoresSafeArea(.all)
                
                VStack (spacing: 0) {
                    HeaderView(showSettingMenu: $showSettingMenu, showPicker: $showPicker)
                        .frame(width: screen.width - 50)
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                    
                    GeometryReader { geometry in
                        BalanceView(show: self.$showBalance, viewModel: BalanceViewModel(env: env))
                            .offset(y: self.showBalance ? -geometry.frame(in: .global).minY : 0)
                    }
                    .frame(maxWidth: showBalance ? .infinity : screen.width - 40)
                    .frame(height: screen.height * 0.18)
                    .zIndex(showBalance ? 1 : 0)
                    
                    GeometryReader { geometry in
                        BudgetView(viewModel: BudgetViewModel(env: env), show: $showBadget)
                            .offset(y: self.showBadget ? -geometry.frame(in: .global).minY : 0)
                    }
                    .frame(maxWidth: showBadget ? .infinity : screen.width)
                    .frame(height: screen.height * 0.18)
                    .zIndex(showBadget ? 1 : 0)
//
                    GeometryReader { geometry in
                        AnalysisView(show: $showAnalysis,
                                     viewModel: AnalysisViewModel(env: env))
                            .offset(y: self.showAnalysis ? -geometry.frame(in: .global).minY : 0)
                    }
                    .frame(maxWidth: showAnalysis ? .infinity : screen.width - 40)
                    .frame(height: screen.height * 0.40)
                    .zIndex(showAnalysis ? 1 : 0)
                    
                    AdmobBannerView().frame(width: 320, height: 50)
                        .padding(.bottom, 4)
                        .zIndex(2)
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
    let screen = UIScreen.main.bounds
    @EnvironmentObject var env: StatusObject
    @State var showEdit = false
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
            HStack (spacing: 12) {
                Button(action: { withAnimation() { self.showSettingMenu = true}})
                {
                    VStack (alignment: .leading, spacing: 8) {
                        ForEach(0..<3) { i in
                            Rectangle()
                                .frame(width: 24 - CGFloat(i) * 6 , height: 1)
                                .foregroundColor(.text)
                        }
                    }
                }
                
                Button(action: { self.showPicker = true })
                {
                    HStack {
                        Text("\(env.activeMonth)").planeStyle(size: 32)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.text)
                            .opacity(0.8)
                            .offset(y: 5)
                    }
                }
                
                Spacer()
                
                Button(action: { withAnimation() {
                    self.showEdit = true
                }}){
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .thin))
                        .foregroundColor(.text)
                }
                .sheet(isPresented: $showEdit) {
                    EditRecordView(record: nil)
                }
            }
        }
    }
}

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
