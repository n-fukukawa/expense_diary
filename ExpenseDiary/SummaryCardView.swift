//
//  SummaryCardView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/24.
//

import SwiftUI

struct SummaryCardView: View {
    let category: Category
    let amount: Int
    
    var body: some View {
        VStack {
            HStack (spacing: 20) {
                ZStack {
                    Circle().foregroundColor(.gray).opacity(0.1)
                    Image(category.icon.name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.text).opacity(0.8)
                }
                .frame(width: 50, height: 50)
                
                VStack (alignment: .leading, spacing: 2) {
                    Text(category.name).planeStyle(size: 16)
                }
                Spacer()
                Text("\(amount)円").planeStyle(size: 16)
            }
            Divider()
        }
        .padding(.bottom, 16)
        .padding(.horizontal, 32)
        .background(Color.backGround)
    }
}
