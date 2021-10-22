//
//  Extensions.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import SwiftUI


extension Color {
    static let backGround    = Color(hex: "FCFCFE")
    static let text          = Color(hex: "707076")
    static let nonActive     = Color(hex: "C6C6CC")
    
    static let main          = Color(hex: "90c8da")
    static let darkMain      = Color(hex: "548ea0")
    static let sub           = Color(hex: "6a4e2d") //バーントアンバー
    static let accent        = Color(hex: "536078")
    static let warning       = Color(hex: "CC1030")

    static let neuBackGround = Color(hex: "F3F4F9")
    static let dropShadow    = Color(hex: "707079")
    static let dropLight     = Color(hex: "FFFFFF")

}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(red: Double(r) / 0xff, green: Double(g) / 0xff, blue: Double(b) / 0xff)
    }
}

extension Text {
    func planeStyle(size: CGFloat, tracking: CGFloat = 2) -> some View {
        self
            .tracking(tracking)
            .font(Font.custom("NotoSansJP-Regular", size: size))
            .foregroundColor(.text)
    }
    
    func mainStyle(size: CGFloat, tracking: CGFloat = 2) -> some View {
        self
            .tracking(tracking)
            .font(Font.custom("NotoSansJP-Regular", size: size))
            .foregroundColor(.main)
    }
    
    func nonActiveStyle(size: CGFloat, tracking: CGFloat = 2) -> some View {
        self
            .tracking(tracking)
            .font(Font.custom("NotoSansJP-Regular", size: size))
            .foregroundColor(.nonActive)
    }
    
    func subStyle(size: CGFloat, tracking: CGFloat = 2) -> some View {
        self
            .tracking(tracking)
            .font(Font.custom("NotoSansJP-Regular", size: size))
            .foregroundColor(.sub)
    }
    
    func outlineStyle(size: CGFloat, tracking: CGFloat = 2) -> some View {
        self
            .tracking(tracking)
            .font(Font.custom("NotoSansJP-Regular", size: size))
            .foregroundColor(.white)
    }
    
    func warningStyle(size: CGFloat, tracking: CGFloat = 2) -> some View {
        self
            .tracking(tracking)
            .font(Font.custom("NotoSansJP-Regular", size: size))
            .foregroundColor(.warning)
    }
}

extension View {
    func customTextField() -> some View {
        self
            .padding(.vertical, 10)
            .foregroundColor(.text)
            .background(Color.white)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
