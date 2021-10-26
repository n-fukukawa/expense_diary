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
        formatter.dateFormat = "M-d E"
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(formatter.string(from: recordCell.date)).planeStyle(size: 14)
                Spacer()
            }
            HStack (spacing: 20) {
                ZStack {
                    Circle().foregroundColor(.gray).opacity(0.1)
                    Image(recordCell.category.icon.name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.text).opacity(0.8)
                }
                .frame(width: 50, height: 50)
                
                VStack (alignment: .leading, spacing: 2) {
                    Text(recordCell.category.name).planeStyle(size: 16)
                    Text(recordCell.memo).planeStyle(size: 13)
                }
                Spacer()
                Text("\(recordCell.amount)円").planeStyle(size: 16)
            }
            Divider()
        }
        .padding(.bottom, 16)
        .padding(.horizontal, 32)
        .background(Color.backGround)
        .onTapGesture {
            self.show.toggle()
        }
        .sheet(isPresented: $show) {
            EditRecordView(record: recordCell)
        }
    }
}
struct RecordCardView_Previews: PreviewProvider {
    static var previews: some View {
        RecordCardView(recordCell: RecordCell(id: "1", date: Date(), category: Category(), amount: 1000, memo: "memomemo", created_at: Date(), updated_at: Date()))
    }
}
