//
//  Extensions.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import SwiftUI


extension Color {
    static let backGround    = Color(hex: "FFFFFF")
    static let text          = Color(hex: "909096")
//    static let nonActive     = Color(hex: "C6C6CC")
    
//    static let themeLight    = Color(hex: "8DC6FA")
//    static let themeDark     = Color(hex: "2878D9")
    
    static let successLight  = Color(hex: "3ab482")
    static let successDark   = Color(hex: "36a474")
    static let dangerLight   = Color(hex: "f8b856")
    static let dangerDark    = Color(hex: "f3d95b")
    static let warningLight  = Color(hex: "e14153")
    static let warningDark   = Color(hex: "d93245")
    
//    static let main          = Color(hex: "88c2d4")
//    static let darkMain      = Color(hex: "508495")
//    static let sub           = Color(hex: "6a4e2d") //バーントアンバー
//    static let accent        = Color(hex: "536078")
    
//    static let dropShadow    = Color(hex: "000000")
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

extension Font {
    static func appFont(size: CGFloat) -> UIFont {
        return UIFont(name: "NotoSansJP-Thin", size: size)!
    }
}

extension Text {
    func style(_ font: Font = .body, weight: Font.Weight = .light, tracking: CGFloat = 2, color: Color = .secondary) -> some View {
        self
            .tracking(tracking)
            .font(font)
            .fontWeight(weight)
            .lineLimit(1)
            .foregroundColor(color)
    }
}

extension View {
    func myShadow(radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0, valid: Bool = true) -> some View {
        self.shadow(color: .primary.opacity(valid ? 0.2 : 0), radius: radius, x: x, y: y)
    }
}

extension View {
    func customTextField() -> some View {
        self
            .font(.title3)
            .foregroundColor(.secondary)
            .padding(6)
            .padding(.trailing, 6)
            .background(Color.gray.opacity(0.08))
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

extension Date {
    func fixed(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date {
        
        var comp = DateComponents()
        comp.year   = year    ?? Calendar.current.component(.year, from: self)
        comp.month  = month   ?? Calendar.current.component(.month, from: self)
        comp.day    = day     ?? Calendar.current.component(.day, from: self)
        comp.hour   = hour    ?? Calendar.current.component(.hour, from: self)
        comp.minute = minute  ?? Calendar.current.component(.minute, from: self)
        comp.second = second  ?? Calendar.current.component(.second, from: self)
        
        return Calendar.current.date(from: comp)!
    }
    
    func added(year: Int = 0, month: Int = 0, day: Int = 0, hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date {
        
        var comp = DateComponents()
        comp.year   = year   + Calendar.current.component(.year, from: self)
        comp.month  = month  + Calendar.current.component(.month, from: self)
        comp.day    = day    + Calendar.current.component(.day, from: self)
        comp.hour   = hour   + Calendar.current.component(.hour, from: self)
        comp.minute = minute + Calendar.current.component(.minute, from: self)
        comp.second = second + Calendar.current.component(.second, from: self)
        
        return Calendar.current.date(from: comp)!
    }
    
    init(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) {
        self.init(
            timeIntervalSince1970: Date().fixed(
                year:   year,
                month:  month,
                day:    day,
                hour:   hour,
                minute: minute,
                second: second
            ).timeIntervalSince1970
        )
    }
}

extension Date {
    func getStartOfDay(offset: Int = 0) -> Date {
        let date = self.added(day: offset)
        return self.fixed(year: date.year, month: date.month, day: date.day, hour: 0, minute: 0, second: 0)
    }
    
    func getEndOfDay(offset: Int = 0) -> Date {
        var date = self.added(day: offset + 1)
        date = date.fixed(year: date.year, month: date.month, day: date.day, hour: 0, minute: 0, second: 0)
        return date.added(second: -1)
    }
    
    func getStartOfMonth(offset: Int = 0) -> Date {
        let date = self.added(month: offset)
        return self.fixed(year: date.year, month: date.month, day: 1, hour: 0, minute: 0, second: 0)
    }
    
    func getEndOfMonth(offset: Int = 0) -> Date {
        var date = self.added(month: offset + 1)
        date = date.fixed(year: date.year, month: date.month, day: 1, hour: 0, minute: 0, second: 0)
        return date.added(second: -1)
    }
}

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isEndOfMonth: Bool {
        self.getEndOfDay() == self.getEndOfMonth()
    }
}

extension Date {
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    var second: Int {
        return Calendar.current.component(.second, from: self)
    }
    
    var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
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

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
