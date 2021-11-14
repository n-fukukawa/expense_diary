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
        VStack (spacing: 0) {
            VStack (spacing: 0) {
                HStack (spacing: 12) {
                    Image(category.icon.name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color("darkGray")).opacity(0.8)
                    Text(category.name).style(.body)
                    Spacer()
                    Text("\(amount)円").style(.body, tracking: 1)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            .background(Color("backGround"))
            
            Divider()
        }
    }
}
