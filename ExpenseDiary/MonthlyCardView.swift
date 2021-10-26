//
//  MonthlyCardView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/24.
//

import SwiftUI

struct MonthlyCardView: View {
    let yearMonth: YearMonth
    let amount: Int
    @State var show = false
    
    init(yearMonth: YearMonth, amount: Int) {
        self.yearMonth = yearMonth
        self.amount = amount
    }
    
    var body: some View {
        VStack {
            HStack (spacing: 20) {
                Text(yearMonth.fullDesc).planeStyle(size: 16)
                Spacer()
                Text("\(amount)円").planeStyle(size: 16)
            }
            Divider()
        }
        .padding(.bottom, 16)
        .padding(.horizontal, 32)
        .background(Color.backGround)
        .onTapGesture {
            self.show.toggle()
        }
    }
}
