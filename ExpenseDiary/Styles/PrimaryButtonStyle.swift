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
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.main.opacity(configuration.isPressed ? 0.3 : 1))
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
