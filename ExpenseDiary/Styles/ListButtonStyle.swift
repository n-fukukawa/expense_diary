//
//  ListButtonStyle.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/11/13.
//

import SwiftUI

struct ListButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? Color("secondary").opacity(0.2) : Color("backGround"))
    }
}

struct ListButtonStyle_Preview: PreviewProvider {
    static var previews: some View {
        Button(action:{}){
            Text("Button").foregroundColor(.white)
        }
        .buttonStyle(ListButtonStyle())
    }
}
