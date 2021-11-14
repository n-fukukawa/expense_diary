//
//  PrimaryButtonStyle.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/05.
//

import SwiftUI

struct CalculatorButtonStyle: ButtonStyle {
    let key: CalcKey
    func makeBody(configuration: Self.Configuration) -> some View {
        let isSpecial = CalcKey.special().firstIndex(of: key) != nil
        let isOperand = CalcKey.operands().firstIndex(of: key) != nil
            configuration.label
                .font(.system(size: isOperand ? 24 : 20 , weight: .medium))
                .foregroundColor(isSpecial ? Color("themeDark") : Color("secondary"))
                .padding(10)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isSpecial
                                ? Color.gray.opacity(configuration.isPressed ? 0.3 : 0.1)
                                : Color.gray.opacity(configuration.isPressed ? 0.3 : 0.001))
                .border(Color("secondary").opacity(0.2), width: 0.5)
    }
}
