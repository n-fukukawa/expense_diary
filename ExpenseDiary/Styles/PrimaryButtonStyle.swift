//
//  PrimaryButtonStyle.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/05.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(LinearGradient(gradient: Gradient(colors: [Color("themeDark"), Color("themeLight")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            .opacity(configuration.isPressed ? 0.3 : 1))
            .cornerRadius(5)
    }
}

struct PrimaryButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button(action:{}){
            Text("Button").foregroundColor(.white)
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}
