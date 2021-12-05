//
//  CalendarView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/11/04.
//

import SwiftUI

struct CalendarView: View {
    let screen = UIScreen.main.bounds
    @EnvironmentObject var env: StatusObject
    @ObservedObject var viewModel: CalendarViewModel
    @State var clickedDate: DateCell?
    @State var selectedIndex: Int = 0
    
    @State var longPressed = false

    
    let height: CGFloat
    
    private func getColor(date: Date) -> Color {
        if !viewModel.isSameMonth(date) {
            return Color("secondary").opacity(0.3)
        }
        
        return Color("secondary").opacity(0.8)
    }
    
    var body: some View {
        VStack (spacing: 0) {
            let columns: [GridItem] = Array(repeating: .init(.fixed(screen.width / 7), spacing: 0), count: 7)
        
            // 曜日
            LazyVGrid(columns: columns, spacing: 0) {
                let header = self.viewModel.getCalendarHeader()
                ForEach(header, id: \.self) { week in
                    Text(week)
                        .style(.caption, weight: .regular, color: week == "日" ? Color("sunday") : (week == "土" ? Color("saturday") : .primary.opacity(0.7)))
                        .padding(2)
                        .frame(maxWidth: .infinity)
                        .background(Color("lightGray"))
//                        .background((week == "日" ? Color("sunday") : (week == "土" ? Color("saturday") : Color("lightGray"))))
                        .border(Color("secondary").opacity(0.3), width: 0.5)
                }
            }
            .frame(width: screen.width)
            
            // 本体
            GeometryReader { geometry in
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(viewModel.amounts, id: \.key) { date, amount in
                            let expense = amount[.expense]!
                            let income = amount[.income]!
                            Button (action: {
                                if self.longPressed {
                                    self.longPressed = false
                                } else {
                                    self.clickedDate = DateCell(date: date)
                                }
                            }) {
                                VStack(spacing: 0) {
                                    HStack (spacing: 4) {
                                        Text(String(date.day))
                                            .style(.caption, weight: .medium, tracking: 0, color: getColor(date: date))
                                            .scaleEffect(1.2)
                                            .padding(.leading, 4)
                                            .padding(.top, 2)
                                        if date.isToday {
                                            Circle()
                                                .foregroundColor(Color(env.themeLight))
                                                .frame(width: 4, height: 4)
                                        }
                                        Spacer()
                                    }
                                    Spacer(minLength: 0)
                                    HStack {
                                        VStack (spacing: 0) {
                                            Text("\(income)")
                                                .style(.caption, tracking: 0, color: Color(env.themeLight))
                                                .opacity(viewModel.isSameMonth(date) && income != 0 ? 1 : 0)
                                                .scaleEffect(0.8)
                                                .frame(maxWidth: .infinity, alignment: .trailing)
                                            Text("\(expense)")
                                                .style(.caption, tracking: 0)
                                                .opacity(viewModel.isSameMonth(date) && expense != 0 ? 1 : 0)
                                                .scaleEffect(0.8)
                                                .frame(maxWidth: .infinity, alignment: .trailing)
                                        }
                                    }
                                }
                                .frame(height: (geometry.frame(in: .local).height - 120 - 20) / 6)
                                .frame(minHeight: 42)
                                .border(Color("secondary").opacity(0.4), width: 0.5)
                                .contentShape(Rectangle())
                            }
                            .simultaneousGesture(
                                LongPressGesture().onEnded{ _ in
                                    longPressed = true
                                    self.env.balanceViewDate = date
                                    self.env.viewType = .balance
                                }
                            )
                            .sheet(item: $clickedDate) { date in
                                EditRecordView(clickedDate: date).environmentObject(env)
                            }
                        }
                    }
                    .border(Color("secondary").opacity(0.4), width: 0.5)
            }
        }
    }
}

struct DateCell: Identifiable {
    var id = UUID()
    let date: Date
}
