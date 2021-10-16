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
    
    init() {
//        let realm = try! Realm()
//
//        try! realm.write {
//             realm.deleteAll()
//        }
//        Icon.seed()
//        Category.seed()
//        Record.seed()
    }
    
    var body: some View {
        ZStack {
            Color.main.ignoresSafeArea(.all)
            VStack(spacing: 0) {
                HeaderView().padding(.horizontal, 30).padding(.bottom, 16)
                MainView()
            }
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

struct HeaderView: View {
    @EnvironmentObject var env: StatusObject
    @State var showSettingMenu = false
    @State var showPicker = false
    let formatter = DateFormatter()
    
    init() {
        formatter.dateFormat = "M/d"
    }
    var body: some View {
        HStack {
            if env.navItem == .list {
                HStack {
                    Button(action: { self.showPicker = true }) {
                        Text("\(env.activeMonth)").outlineStyle(size: 36)
                    }
                    VStack(alignment: .leading) {
                        Text(String(describing: env.startDateYear)).outlineStyle(size: 14)
                        HStack(spacing: 3) {
                            Text("\(formatter.string(from: env.startDate))").outlineStyle(size: 14)
                            Text("-").outlineStyle(size: 14)
                            Text("\(formatter.string(from: env.endDate))").outlineStyle(size: 14)
                        }
                    }
                }
            } else {
                HStack {
                    Button(action: { self.showPicker = true }) {
                        Text("\(String(describing: env.activeYear))").outlineStyle(size: 36)
                    }
                }
            }
            
            Spacer()
            Button(action: { self.showSettingMenu = true }){
                Image(systemName: "gearshape")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
            }
            .fullScreenCover(isPresented: $showSettingMenu) {
                SettingMenuView(isActive: $showSettingMenu)
            }
        }
        .foregroundColor(.white)
    }
}

struct MainView: View {
    var body: some View {
        ZStack {
            Rectangle().cornerRadius(25.0, corners: [.topLeft, .topRight])
                .ignoresSafeArea(edges: .bottom)
                .foregroundColor(.backGround)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: -2)
            
            VStack {
                 ContentView().padding(.horizontal, 16).padding(.top, 24)
                 Spacer()
                 AdmobBannerView().frame(width: 320, height: 50).padding(.bottom, 10)
                 GlobalNavView()
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var env: StatusObject
    
    var body: some View {
        switch (env.navItem) {
            case .list  : ListView(env: env)
            case .chart : ChartView()
        }
    }
}

struct GlobalNavView: View {
    @EnvironmentObject var env: StatusObject
    @State var isShowing = false
    var body: some View {
        HStack {
            Button(action: {
                self.env.navItem = .list
            }){
                Image(systemName: "list.bullet")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(self.env.navItem == .list ? .main : .nonActive)
            }
            Spacer()
            Button(action: {
                self.isShowing = true
            }){
                ZStack {
                    Circle().foregroundColor(.accent).shadow(color: .black.opacity(0.1), radius: 3, x: 1, y: 1)
                    Image(systemName: "plus")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 15, height: 15)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: 56, height: 56)
            }
            .sheet(isPresented: $isShowing) {
                EditRecordView()
            }
            Spacer()
            Button(action: {
                self.env.navItem = .chart
            }){
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 30, weight: .thin))
                    .foregroundColor(self.env.navItem == .chart ? .main : .nonActive)
            }
        }
        .padding(.horizontal, 40)
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
