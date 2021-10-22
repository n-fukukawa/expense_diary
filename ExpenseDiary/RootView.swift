//
//  ContentView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import SwiftUI
import RealmSwift

struct RootView: View {
    @EnvironmentObject var env: StatusObject
    @State var showSettingMenu = false
    @State var showPicker = false
    @State var contentType: ContentType = .records
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
//
//        Category.seed()
//        Record.seed()
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Color.main.ignoresSafeArea(.all)
                VStack(spacing: 0) {
                    HeaderView(showSettingMenu: $showSettingMenu, showPicker: $showPicker)
                        .padding(.horizontal, 30)
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                    TabView(contentType: $contentType)
                        .padding(.bottom, 10)
                    MainView(contentType: $contentType)
                }
                
                GlobalNavView()
                    .padding(.bottom, 12)
                    .padding(.trailing, 20)
                    .offset(y: -50)
                
                ZStack {
                    Color.black.opacity(self.showModal ? 0.1 : 0).ignoresSafeArea(.all)
                }
                .onTapGesture {
                    withAnimation {
                        self.showSettingMenu = false
                        self.showPicker = false
                    }
                }

                SettingMenuView(isActive: $showSettingMenu).transition(.slide)
                
                if showPicker {
                    VStack {
                        Text("a").padding()
                    }.modifier(ModalCardModifier(active: showPicker))
                }
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
        HStack {
            HStack  {
                Button(action: { self.showPicker = true }) {
                    Text("\(env.activeMonth)").subStyle(size: 36)
                }
                VStack (alignment: .leading, spacing: 0) {
                    Text(String(describing: env.startDateYear))
                        .subStyle(size: 12, tracking: 1)
                        .offset(y: 2)
                    HStack(spacing: 3) {
                        Text("\(formatter.string(from: env.startDate))")
                            .subStyle(size: 12, tracking: 1)
                        Text("-").subStyle(size: 12, tracking: 1)
                        Text("\(formatter.string(from: env.endDate))")
                            .subStyle(size: 12, tracking: 1)
                    }
                }
            }
            Spacer()
            Button(action: { withAnimation() {
                self.showSettingMenu = true
            }}){
                VStack (spacing: 8) {
                    ForEach(0..<3) { _ in
                        Rectangle()
                            .frame(width: 24, height: 1)
                            .foregroundColor(.sub)
                    }
                }
            }
        }
    }
}


struct TabView: View {
    @Binding var contentType: ContentType
    var body: some View {
        HStack(spacing: 0) {
            ForEach(ContentType.all(), id: \.self) { contentType in
                let is_active = self.contentType == contentType
                Button(action: {
                    self.contentType = contentType
                }){
                    VStack(spacing: 4) {
                        Text(contentType.rawValue)
                            .subStyle(size: is_active ? 20 : 16, tracking: 1)
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 20, height: 2)
                            .opacity(is_active ? 1 : 0)
                            .foregroundColor(.sub)
                    }
                    .frame(height: 46)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct MainView: View {
    @Binding var contentType: ContentType
    var body: some View {
        ZStack {
//            Rectangle()
//                .cornerRadius(25.0, corners: [.topLeft, .topRight])
//                .foregroundColor(.neuBackGround)
//                .ignoresSafeArea(edges: .bottom)
            
            VStack {
                 ContentView(type: $contentType)
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .padding(.bottom, 20)
                 Spacer()
                 AdmobBannerView().frame(width: 320, height: 50)
            }
        }
        
    }
}

struct ContentView: View {
    @EnvironmentObject var env: StatusObject
    @Binding var type: ContentType
    
    var body: some View {
        switch (type) {
            case .records  : ListView(env: env)
            case .summary  : SummaryView(env: env)
            case .chart    : ChartView()
        }
    }
}

struct GlobalNavView: View {
    @EnvironmentObject var env: StatusObject
    @State var isShowing = false
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        self.isShowing = true
                    }){
                        ZStack {
                            Circle().foregroundColor(.sub)
                                .shadow(color: .sub.opacity(0.5), radius: 6, x: 2, y: 2)
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(width: 56, height: 56)
                    }
                    .sheet(isPresented: $isShowing) {
                        EditRecordView()
                    }
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
        let devices = ["iPhone 12", "iPhone 8", "iPad Pro(12.9-inch) (3rd generation)"]
        ForEach(devices, id: \.self) { device in
            RootView().environmentObject(StatusObject())
                       .previewDevice(.init(rawValue: device))
                        .environment(\.locale, Locale(identifier: "ja_JP"))
        }
    }
}

