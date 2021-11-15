//
//  ChartView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/09.
//

import SwiftUI
import Charts

struct ChartView: UIViewRepresentable {
    typealias UIViewType = BarChartView

    let dataSet: [(key: YearMonth, value: Int)]
    let balance: Bool
    var env: StatusObject
    
    var data: [ChartDataEntry] = []
    var descs: [String] = []
    
    init(dataSet: [(key: YearMonth, value: Int)], balance: Bool, env: StatusObject) {
        self.dataSet = dataSet
        self.balance = balance
        self.env = env

        var count: Double = 0
        self.dataSet.forEach({ set in
            self.data.append(BarChartDataEntry(x: count, y: Double(set.value)))
            self.descs.append("\(set.key.monthDesc)")
            count += 1
        })
    }
    
    func setData() -> BarChartData {
        let dataSet = BarChartDataSet(entries: self.data)
        
        let colorSets = Array(self.dataSet.map{$0.value < 0 ? UIColor(Color(hex: "cccccc")) : UIColor(Color(env.themeLight))})
        
        dataSet.setColors(colorSets[0], colorSets[1], colorSets[2], colorSets[3], colorSets[4], colorSets[5], colorSets[6], colorSets[7], colorSets[8], colorSets[9], colorSets[10], colorSets[11], colorSets[12])

        let barChartData =  BarChartData(dataSet: dataSet)
        barChartData.barWidth = Double(0.4)
        
        return barChartData
    }
    
    
    func makeUIView(context: Context) -> BarChartView {
        let chart = BarChartView()
        chart.data = self.setData()
        
        
        // 振る舞い
        chart.pinchZoomEnabled = false
        chart.doubleTapToZoomEnabled = false
        chart.dragXEnabled = true
        chart.dragYEnabled = false
        chart.scaleXEnabled = false
        chart.scaleYEnabled = false
        
        chart.highlightPerTapEnabled = false
        
        chart.leftAxis.axisMinimum = 0
        
        chart.animate(yAxisDuration: 0.8)
        
        chart.backgroundColor = UIColor(Color("backGround"))
        chart.legend.enabled = false
        chart.rightAxis.enabled = false
        
        chart.data!.setDrawValues(false)
        
        chart.setVisibleXRangeMaximum(4)
        chart.moveViewToX(12)
        
        
        let xAxis = chart.xAxis
        xAxis.axisLineColor = UIColor(.primary)
        xAxis.gridLineWidth = 1
        xAxis.gridColor = UIColor(Color("secondary")).withAlphaComponent(0.1)
        xAxis.labelPosition = .bottom
        xAxis.labelCount = 13
        xAxis.labelFont = UIFont.systemFont(ofSize: 12)
        xAxis.labelTextColor = UIColor(Color("secondary"))
        
        xAxis.valueFormatter = IndexAxisValueFormatter(values: descs)
        xAxis.granularity = 1
        
        let yAxis = chart.leftAxis
        yAxis.axisLineColor = UIColor(.primary)
        yAxis.gridLineWidth = 1
        yAxis.gridColor = UIColor(Color("secondary")).withAlphaComponent(0.1)
        yAxis.labelPosition = .outsideChart
        yAxis.labelFont = UIFont.systemFont(ofSize: 12)
        yAxis.labelTextColor = UIColor(Color("secondary"))
        
        return chart
    }
    
    func updateUIView(_ uiView: BarChartView, context: Context) {
        if balance {
            uiView.leftAxis.resetCustomAxisMin()
        } else {
            uiView.leftAxis.axisMinimum = 0
        }
        uiView.data = self.setData()
        uiView.data!.setDrawValues(false)
        uiView.backgroundColor = UIColor(Color("backGround"))

        uiView.animate(yAxisDuration: 0.8)
    }
}
