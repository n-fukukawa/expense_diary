//
//  RecordCardView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/24.
//

import SwiftUI

struct RecordCardView: View {
    let recordCell: RecordCell
    let formatter = DateFormatter()
    @State var show = false
    
    init(recordCell: RecordCell) {
        self.recordCell = recordCell
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M-d (E)"
    }
    
    var body: some View {
        VStack (spacing: 0) {
            VStack (spacing: 8) {
                HStack {
                    Text(formatter.string(from: recordCell.date)).style(.body, weight: .bold, tracking: 0).opacity(0.8)
                    Spacer()
                }
                HStack (spacing: 20) {                    
                    VStack (alignment: .leading, spacing: 2) {
                        Text(recordCell.category.name).style(.title3)
                        if !recordCell.memo.isEmpty {
                            Text(recordCell.memo).style(.caption)
                        }
                    }
                    Spacer()
                    Text("\(recordCell.amount)円").style(.title3, tracking: 1)
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 16)
            
            Divider()
        }
        .background(Color("backGround"))
        .onTapGesture {
            self.show.toggle()
        }
        .sheet(isPresented: $show) {
            EditRecordView(record: recordCell)
        }
    }
}
//struct RecordCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecordCardView(recordCell: RecordCell(id: "1", date: Date(), category: Category(), amount: 1000, memo: "memomemo", created_at: Date(), updated_at: Date()))
//    }
//}
