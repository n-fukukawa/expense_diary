//
//  RecordCardView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/24.
//

import SwiftUI

struct RecordCardView: View {
    let recordCell: RecordCell
    @EnvironmentObject var env: StatusObject
    @State var show = false
    
    init(recordCell: RecordCell) {
        self.recordCell = recordCell
    }
    
    var body: some View {
        Button (action: {self.show.toggle()}) {
//        NavigationLink(destination: EditRecordView(record: recordCell)) {
            VStack (spacing: 0) {
                HStack (spacing: 12) {
                    Image("\(recordCell.category.icon.name)")
                        .resizable().aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color("darkGray"))
                    
                    Text(recordCell.category.name).style(.body).offset(x: -4)
                    Text(recordCell.memo).style(.caption, tracking: 1)
                    Spacer()
                    Text("\(recordCell.amount)円").style(.body, tracking: 1)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                
                if #available(iOS 15.0, *) {
                } else {
                    Divider()
                }

            }
        }
        .buttonStyle(ListButtonStyle())
        .sheet(isPresented: $show) {
            EditRecordView(record: recordCell).environmentObject(env)
        }
    }
}
