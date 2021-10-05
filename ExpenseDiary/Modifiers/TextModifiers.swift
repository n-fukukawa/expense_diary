//
//  NormalText.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/03.
//

import SwiftUI

struct NormalText: ViewModifier {
    let size: CGFloat
    func body(content: Content) -> some View {
        content
            .font(Font.custom("NotoSansJP-Regular", size: size))
    }
}

struct NormalText_Previews: PreviewProvider {
    static var previews: some View {
        Text("hello world").modifier(NormalText(size: 16))
    }
}

struct BoldText: ViewModifier {
    let size: CGFloat
    func body(content: Content) -> some View {
        content
            .font(Font.custom("NotoSansJP-Medium", size: size))
    }
}

struct BoldText_Previews: PreviewProvider {
    static var previews: some View {
        Text("hello world").modifier(BoldText(size: 16))
    }
}
