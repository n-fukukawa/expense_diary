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
    
    let preview: Bool
    let months = ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"]
    
    
    let data: [ChartDataEntry] = [
        ChartDataEntry(x: 0, y: 2900),
        ChartDataEntry(x: 1, y: 3500),
        ChartDataEntry(x: 2, y: 3200),
        ChartDataEntry(x: 3, y: 1800),
        ChartDataEntry(x: 4, y: 2600),
        ChartDataEntry(x: 5, y: 4600),
    ]
    
    func getData() -> LineChartData {
        let dataSet = LineChartDataSet(entries: data)
        
        let gradientColors = [
                              UIColor(Color(hex: "a0d8ea")).cgColor,
                              UIColor(Color(hex: "35a0ce")).cgColor,
                             // UIColor(.purple).cgColor
        ] as CFArray // Colors of the gradient
        let colorLocations:[CGFloat] = [0.0, 0.8, 0.95] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
//        dataSet.mode = .cubicBeziers
        dataSet.fill = Fill(linearGradient: gradient!, angle: 90)
        dataSet.fillAlpha = 0.2
        dataSet.drawFilledEnabled = true
        dataSet.setCircleColor(UIColor(Color(hex: "35a0ce")).withAlphaComponent(0.5))
        dataSet.circleRadius = 5
        dataSet.setColor(UIColor(Color(hex: "35a0ce")), alpha: 0.5)
//        dataSet.drawCirclesEnabled = false
        

        return LineChartData(dataSet: dataSet)
    }
    
    func makeUIView(context: Context) -> LineChartView {
        let lineChart = LineChartView()
        lineChart.data = self.getData()
        
        // 振る舞い
        lineChart.pinchZoomEnabled = false
        lineChart.doubleTapToZoomEnabled = false
        lineChart.dragEnabled = false
        lineChart.scaleXEnabled = false
        lineChart.scaleYEnabled = false
        
        if preview {
            lineChart.highlightPerTapEnabled = false
        }
        
        
        lineChart.backgroundColor = UIColor(.backGround)
        lineChart.legend.enabled = false
        lineChart.rightAxis.enabled = false
        
        lineChart.data!.setDrawValues(false)
        lineChart.leftAxis.axisMinimum = 0
        
        lineChart.animate(yAxisDuration: 1)
        
        let xAxis = lineChart.xAxis
        xAxis.axisLineColor = UIColor(.text)
        xAxis.gridLineWidth = 0
        xAxis.labelPosition = .bottom
        xAxis.labelCount = 5
        xAxis.labelFont = Font.appFont(size: 11)
        xAxis.labelTextColor = UIColor(.text)
        
        xAxis.valueFormatter = IndexAxisValueFormatter(values:months)
        xAxis.granularity = 1
        
        let yAxis = lineChart.leftAxis
        yAxis.axisLineColor = UIColor(.text)
        yAxis.gridLineWidth = 1
        yAxis.gridColor = UIColor(.text).withAlphaComponent(0.3)
        //yAxis.setLabelCount(3, force: false)
        yAxis.labelPosition = .outsideChart
        yAxis.labelFont = Font.appFont(size: 11)
        yAxis.labelTextColor = UIColor(.text)
        
        return lineChart
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        //
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView(preview: false).frame(height: 300)
    }
}
