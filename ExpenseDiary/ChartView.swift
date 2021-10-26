//
//  ChartView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/09.
//

import SwiftUI
import Charts

struct ChartView: UIViewRepresentable {
    
    typealias UIViewType = LineChartView
    
    let dataSet: [(key: YearMonth, value: Int)]
    let colorSet: ColorSet
    let preview: Bool
    
    var data: [ChartDataEntry] = []
    var descs: [String] = []
    
    init(dataSet: [(key: YearMonth, value: Int)], colorSet: ColorSet, preview: Bool) {
        self.dataSet = dataSet
        self.colorSet = colorSet
        self.preview = preview

        var count: Double = 0
        self.dataSet.forEach({ set in
            self.data.append(ChartDataEntry(x: count, y: Double(set.value)))
            self.descs.append("\(set.key.monthDesc)")
            count += 1
        })
    }
    
    func setData() -> LineChartData {
        let dataSet = LineChartDataSet(entries: data)
        
        let gradientColors = [
            UIColor(colorSet.getColor1()).withAlphaComponent(0.5).cgColor,
            UIColor(colorSet.getColor2()).withAlphaComponent(1).cgColor,
        ] as CFArray
        let colorLocations:[CGFloat] = [0.0, 0.8, 0.95] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
//        dataSet.mode = .cubicBeziers
        dataSet.fill = Fill(linearGradient: gradient!, angle: 90)
        dataSet.fillAlpha = 0.2
        dataSet.drawFilledEnabled = true
        dataSet.setCircleColor(UIColor(colorSet.getColor1()).withAlphaComponent(0.5))
        dataSet.circleRadius = 5
        dataSet.setColor(UIColor(colorSet.getColor1()), alpha: 0.5)
//        dataSet.drawCirclesEnabled = false
        

        return LineChartData(dataSet: dataSet)
    }
    
    
    func makeUIView(context: Context) -> LineChartView {
        let lineChart = LineChartView()
        lineChart.data = self.setData()
        
        // 振る舞い
        lineChart.pinchZoomEnabled = false
        lineChart.doubleTapToZoomEnabled = false
        lineChart.dragEnabled = false
        lineChart.scaleXEnabled = false
        lineChart.scaleYEnabled = false
        
        //if preview {
            lineChart.highlightPerTapEnabled = false
        //}
        
        lineChart.animate(yAxisDuration: 0.8)
        
        lineChart.backgroundColor = UIColor(.backGround)
        lineChart.legend.enabled = false
        lineChart.rightAxis.enabled = false
        
        lineChart.data!.setDrawValues(false)
        lineChart.leftAxis.axisMinimum = 0
        
        let xAxis = lineChart.xAxis
        xAxis.axisLineColor = UIColor(.text)
        xAxis.gridLineWidth = 0
        xAxis.labelPosition = .bottom
        xAxis.labelCount = 5
        xAxis.labelFont = Font.appFont(size: 12)
        xAxis.labelTextColor = UIColor(.text)
        
        xAxis.valueFormatter = IndexAxisValueFormatter(values: descs)
        xAxis.granularity = 1
        
        let yAxis = lineChart.leftAxis
        yAxis.axisLineColor = UIColor(.text)
        yAxis.gridLineWidth = 1
        yAxis.gridColor = UIColor(.text).withAlphaComponent(0.3)
        //yAxis.setLabelCount(3, force: false)
        yAxis.labelPosition = .outsideChart
        yAxis.labelFont = Font.appFont(size: 12)
        yAxis.labelTextColor = UIColor(.text)
        
        return lineChart
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {        
        uiView.data = self.setData()
        uiView.data!.setDrawValues(false)
        //uiView.animate(yAxisDuration: 0.8)
    }
}
