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
        VStack(spacing: 0) {
            HStack (spacing: 20) {
                Text(yearMonth.fullDesc).style()
                Spacer()
                Text("\(amount)円").style()
            }
            .padding(.vertical, 12)
            
            if #available(iOS 15.0, *) {
            } else {
                Divider()
            }
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity)
        .background(Color("backGround"))
    }
}
