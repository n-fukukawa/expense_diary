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
                HStack (spacing: 2) {
                    Image(category.icon.name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.secondary).opacity(0.8)
                    .frame(width: 50, height: 50)
                    Text(category.name).style(.title3)
                    Spacer()
                    Text("\(amount)円").style(.title3, tracking: 1)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            .background(Color("backGround"))
            
            Divider()
        }
    }
}
