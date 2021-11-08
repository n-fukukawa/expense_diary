//
//  CalculatorView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/11/06.
//

import SwiftUI

struct CalculatorView: View {
    let screen = UIScreen.main.bounds
    var data = CalcModel()
    @Binding var show: Bool
    @Binding var value: String
    
    
    
    var body: some View {
        VStack(spacing: 0) {
            if show {
                Divider()
            }
            VStack(spacing: 0) {
                HStack {
                    Text("閉じる").style(weight: .bold, color: Color("themeDark"))
                        .onTapGesture {
                            withAnimation(.linear(duration: 0.2)) {
                                self.show = false
                            }
                        }
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.vertical, 6)
                .frame(height: 40)
                let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 4)
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(CalcKey.all(), id: \.self) { key in
                        Button(action: {
                            self.onClickKey(key)
                        }) {
                            if key == .delete {
                                Image(systemName: "delete.left")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Color("themeDark"))
                                    .offset(x: -2)
                            } else {
                                Text("\(key.rawValue)").style(.title3, weight: .medium, color: CalcKey.operands().firstIndex(of: key) != nil ? Color("themeDark") : .secondary)
                            }
                        }
                        .buttonStyle(CalculatorButtonStyle(key: key))
                        
                    }
                }
            }
            .frame(width: screen.width, height: show ? 340 : 0)
            .background(Color("backGround"))
            .ignoresSafeArea(.all)
            .opacity(show ? 1 : 0)
            .zIndex(1)
        }
    }
    
    private func onClickKey(_ key: CalcKey) {
        data.display = value
        
        switch(key){
        case .clear:
            clear()
            break
            
        case .equal:
            let value1 = data.result
            let value2 = NSDecimalNumber(string: data.display)
            
            if data.recentOperand == .divide && value2 == 0 {
                error()
                return
            }
            
            let result = calc(key: data.recentOperand, value1, value2)
            
            if result.doubleValue >= NSDecimalNumber(10).raising(toPower: CalcModel.maximumDigit).doubleValue {
                error()
                return
            }
            
            if result == NSDecimalNumber.notANumber {
                clear()
                return
            }
            
            data.display = result.rounding( accordingToBehavior: NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.plain, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)).description
            data.result = 0
            
            data.recentOperand = .equal
            data.isOperandActive = false
            break
            
        case .plus, .minus, .times, .divide:
            if !data.isOperandActive {
                let value1 = data.result
                let value2 = NSDecimalNumber(string: data.display)
                
                if key == .divide && value2 == 0 && data.recentOperand != CalcKey.equal{
                    error()
                    return
                }
                
                data.result = calc(key: data.recentOperand, value1, value2)
                if data.result.doubleValue >= NSDecimalNumber(10).raising(toPower: CalcModel.maximumDigit).doubleValue {
                    error()
                    return
                }
                
                
                data.display = data.result.description
            }
            
            data.recentOperand = key
            data.isOperandActive = true
            break
            
        case .percent:
            if data.isOperandActive {
                return
            }
            
            let value1 = data.result
            let value2 = NSDecimalNumber(string: data.display)
            
            if value1 != 0 {
                let result = calc(key: .percent, value1, value2)
                
                if result.doubleValue >= NSDecimalNumber(10).raising(toPower: CalcModel.maximumDigit).doubleValue {
                    error()
                    return
                } else {
                    data.display = result.description
                }
                
            } else {
                let result = calc(key: .percent, 1, value2)
                
                if result.doubleValue >= NSDecimalNumber(10).raising(toPower: CalcModel.maximumDigit).doubleValue {
                    error()
                    return
                } else {
                    data.display =  result.description
                }
            }
            
            break
            
            
        case .period:
            if data.isOperandActive {
                data.display = "0" + key.rawValue
            } else if data.hasPeriod {
                return
            } else {
                data.display += key.rawValue
            }
            
            data.isOperandActive = false
            break
            
            
            
        case .inverse:
            if data.display == "0" || data.display == "" || data.isOperandActive {
                return
            }
            
            
            data.display = NSDecimalNumber(string: data.display).multiplying(by: -1).description
            
        case .delete:
            if data.display == "0" {
                return
            }
            
            data.display = String(data.display.dropLast(1))
            if data.display.count == 0 || data.display == "-"  {
                data.display = "0"
            }
            break
            
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            
            if data.isOperandActive {
                data.display = key.rawValue
            } else {
                if data.display == "0" {
                    data.display = String(data.display.dropFirst(1))
                }
                data.display += key.rawValue
            }
            data.isOperandActive = false
            break
        }
        
        if data.display == "-0" {
            data.display = "0"
        }
        
        if data.display.count >= CalcModel.maximumDigit {
            data.display = String(data.display.prefix(CalcModel.maximumDigit))
        }
        
        
        data.hasPeriod = hasPeriod(string: data.display)
        
        self.value = data.display
    }
    
    func calc(key: CalcKey, _ value1: NSDecimalNumber, _ value2: NSDecimalNumber) -> NSDecimalNumber {
        switch key {
        case .plus:
            return value1.adding(value2)
        case .minus:
            return value1.subtracting(value2)
        case .times:
            return value1.multiplying(by: value2)
        case .divide:
            return value1.dividing(by: value2)
        case .percent:
            return value1.multiplying(by: value2.dividing(by: 100))
        default :
            return value2
        }
    }
    
    
    func clear(){
        data.display = "0"
        data.result = 0
        data.recentOperand = .equal
        data.isOperandActive = false
        data.hasPeriod = false
    }
    
    func error(){
        clear()
        data.display = CalcModel.errorString
        self.value = "0"
    }
    
    func hasPeriod(string: String) -> Bool {
        return string.contains(CalcKey.period.rawValue)
    }
}

class CalcModel {
    static let errorString = "E"
    static let maximumDigit = 13
    var display: String = "0"
    var result: NSDecimalNumber = 0
    var recentOperand: CalcKey = .equal
    var isOperandActive = false
    var hasPeriod = false
}
