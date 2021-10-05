//
//  BarCharts.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/05.
//

import SwiftUI

struct BarChartCell: View {
    var value: Double
    var barColor: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(barColor)
            .scaleEffect(CGSize(width: 1, height: value), anchor: .bottom)
    }
}

struct ChartData {
    var label: String
    var value: Int
}

struct BarCharts_Previews: PreviewProvider {
    static var previews: some View {
        BarChartCell(value: 0.5, barColor: .main)
    }
}
