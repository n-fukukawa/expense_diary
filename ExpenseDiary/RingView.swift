//
//  RingView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/23.
//

import SwiftUI

struct RingView: View {
    let color1: Color
    let color2: Color
    let icon: Icon
    let size: CGFloat
    let percent: CGFloat
    
    @Binding var show: Bool
    
    var body: some View {
        let multiplier = size / 44
        let progress = percent > 100 ? 1 : percent / 100
        ZStack {
            Circle()
                .stroke(Color.nonActive, style: StrokeStyle(lineWidth: 5 * multiplier))
                .frame(width: size, height: size)
            Circle()
                .trim(from: show ? 1 - progress : 1, to: 1.0)
                .stroke(LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .topTrailing, endPoint: .bottomLeading), style: StrokeStyle(lineWidth: 5 * multiplier, lineCap: .round, lineJoin: .round, miterLimit: .infinity, dash: [20, 0], dashPhase: 0))
                .rotationEffect(Angle(degrees: 90))
                .rotation3DEffect(Angle(degrees: 180), axis: (x: 1, y: 0, z: 0))
                .frame(width: size, height: size)
                .shadow(color: color2.opacity(0.1), radius: 3 * multiplier, x: 0, y: 3 * multiplier)
                .animation(.easeInOut(duration: 0.5))
            //Text("\(Int(percent))%")
                Image(icon.name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20 * multiplier)
                    .foregroundColor(.nonActive)
        }
        .frame(width: size + 5 * multiplier, height: size + 5 * multiplier)
    }
}

struct RingView_Previews: PreviewProvider {
    static var previews: some View {
        RingView(color1: .blue, color2: .red, icon: Icon.all().first!, size: 90, percent: 75, show: .constant(true))
    }
}
