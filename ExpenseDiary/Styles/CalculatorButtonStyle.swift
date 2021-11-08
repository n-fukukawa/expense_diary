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
        let isOperand = CalcKey.operands().firstIndex(of: key) != nil
            configuration.label
                .padding(10)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(isOperand
                                ? Color.gray.opacity(configuration.isPressed ? 0.3 : 0.1)
                                : Color.gray.opacity(configuration.isPressed ? 0.3 : 0.001))
                .border(Color.secondary.opacity(0.2), width: 0.5)
    }
}
