//
//  RecordSectionHeaderView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/11/13.
//

import SwiftUI

struct RecordSectionHeaderView: View {
    let date: Date
    let recordCells: [RecordCell]
    let formatter = DateFormatter()
    
    init (date: Date, recordCells: [RecordCell]) {
        self.date = date
        self.recordCells = recordCells
        self.formatter.dateFormat = Config.MONTH_DAY_DESC
    }
    var body: some View {
        HStack {
            Text("\(formatter.string(from: date))")
                .style(.caption, weight: .medium, tracking: 1)
                .scaleEffect(1.1)
                .padding(.horizontal, 4)
            Spacer()
            Text("\(RecordCell.getSum(recordCells))円")
                .style(.caption, weight: .regular, tracking: 0)
                .scaleEffect(1.1)
                .padding(.trailing, 12)
        }
    }
}
