//
//  SecondaryButtonStyle.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/05.
//

import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.secondary.opacity(configuration.isPressed ? 0.3 : 1))
            .cornerRadius(5)
    }
}

struct SecondaryButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button(action:{}){
            Text("Button").foregroundColor(.white)
        }
        .buttonStyle(SecondaryButtonStyle())
    }
}
