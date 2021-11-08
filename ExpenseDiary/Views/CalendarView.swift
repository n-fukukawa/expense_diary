//
//  CalendarView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/11/04.
//

import SwiftUI

struct CalendarView: View {
    let screen = UIScreen.main.bounds
    @ObservedObject var viewModel: CalendarViewModel
    @State var clickedDate: DateCell?
    @State var selectedIndex: Int = 0
    
    let height: CGFloat
    
    private func getColor(date: Date) -> Color {
        if !viewModel.isSameMonth(date) {
            return .secondary.opacity(0.3)
        }
//        if date.weekday == 7 {
//            return Color("saturday")
//        }
//        if date.weekday == 1 {
//            return Color("warningLight")
//        }
        
        return .secondary
    }
    
    var body: some View {
        VStack (spacing: 0) {
            let columns: [GridItem] = Array(repeating: .init(.fixed(screen.width / 7), spacing: 0), count: 7)
        
            // 曜日
            LazyVGrid(columns: columns, spacing: 0) {
                let header = self.viewModel.getCalendarHeader()
                ForEach(header, id: \.self) { week in
                    Text(week)
                        .style(.caption, weight: .regular)
                        .padding(2)
                        .frame(maxWidth: .infinity)
                        .background((week == "日" ? Color("warningLight") : (week == "土" ? Color("saturday") : Color.secondary)).opacity(0.2))
                        .border(Color.secondary.opacity(0.2), width: 0.5)
                }
            }
            .frame(width: screen.width)
            
            // 本体
            GeometryReader { geometry in
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(viewModel.amounts, id: \.key) { date, amount in
                            let expense = amount[.expense]!
                            let income = amount[.income]!
                            Button(action: {
                                if !viewModel.isSameMonth(date) {
                                    return
                                }
                                self.clickedDate = DateCell(date: date)
                            }) {
                                VStack(spacing: 0) {
                                    HStack {
                                        Text(String(date.day))
                                            .style(.caption, weight: .medium, tracking: 0, color: getColor(date: date))
                                            .scaleEffect(1.2)
                                            .padding(.leading, 4)
                                            .padding(.top, 2)
                                        Spacer()
                                    }
                                    Spacer(minLength: 0)
                                    HStack {
                                        VStack (spacing: 0) {
                                            Text("\(income)")
                                                .style(.caption, tracking: 0, color: Color("themeDark"))
                                                .opacity(viewModel.isSameMonth(date) && income != 0 ? 1 : 0)
                                                .scaleEffect(0.8)
                                                .frame(maxWidth: .infinity, alignment: .trailing)
                                            Text("\(expense)")
                                                .style(.caption, tracking: 0, color: .secondary)
                                                .opacity(viewModel.isSameMonth(date) && expense != 0 ? 1 : 0)
                                                .scaleEffect(0.8)
                                                .frame(maxWidth: .infinity, alignment: .trailing)
                                        }
                                    }
                                }
                                .contentShape(Rectangle())
                                .frame(height: (geometry.frame(in: .local).height - 120 - 20) / 6)
                                .border(Color.secondary.opacity(0.4), width: 0.5)
                            }
                            .sheet(item: $clickedDate) { date in
                                EditRecordView(clickedDate: date)
                            }
                        }
                    }
                    .border(Color.secondary.opacity(0.4), width: 0.5)
            }
        }
    }
}

struct DateCell: Identifiable {
    var id = UUID()
    let date: Date
}
