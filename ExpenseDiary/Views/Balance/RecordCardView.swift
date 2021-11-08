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
        formatter.dateFormat = "M-d E"
    }
    
    var body: some View {
        VStack (spacing: 0) {
            VStack (spacing: 8) {
                HStack {
                    Text(formatter.string(from: recordCell.date))
                        .style(.caption, weight: .bold, tracking: 0)
                        .scaleEffect(1.1)
                        .opacity(0.9)
                        .offset(x: 1)
                    Spacer()
                }
                HStack (spacing: 12) {
                    Text(recordCell.category.name).style(.title3)
                    Text(recordCell.memo).style(.caption, tracking: 1).scaleEffect(1.2)
                    Spacer()
                    Text("\(recordCell.amount)円").style(.title3, tracking: 1)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 16)
            
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
