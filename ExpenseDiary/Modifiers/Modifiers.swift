//
//  NormalText.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import SwiftUI

struct ModalCardModifier: ViewModifier {
    let active: Bool
    func body(content: Content) -> some View {
        content
            .background(Color.backGround)
            .cornerRadius(10)
            .myShadow(radius: 20, x: 0, y: 20)
            .opacity(active ? 1 : 0)
            .scaleEffect(active ? 0.9 : 0.95)
            .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0))
    }
}

//struct FontModifier: ViewModifier {
//    let size: CGFloat
//    func body(content: Content) -> some View {
//        content
//            .font(Font.custom("NotoSansJP-Regular", size: size))
//            .foregroundColor(.text)
//    }
//}
