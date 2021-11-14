//
//  RingView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/23.
//

import SwiftUI

struct RingView: View {
    let icon: Icon
    let size: CGFloat
    let percent: CGFloat
    @Binding var show: Bool
    
    var isWhite = false
    
    var color1: Color {
        if self.percent < 70 {
            return Color("themeDark").opacity(0.8)
        } else if self.percent < 90 {
            return Color("dangerDark") 
        } else {
            return Color("warningDark")
        }
    }
    
    var color2: Color {
        if self.percent < 70 {
            return Color("themeLight").opacity(0.8)
        } else if self.percent < 90 {
            return Color("dangerLight")
        } else {
            return Color("warningLight")
        }
    }
    
    var body: some View {
        let multiplier = size / 44
        let progress = percent > 100 ? 1 : percent / 100
        ZStack {
            Circle()
                .stroke(isWhite ? Color.white : Color("lightGray"), style: StrokeStyle(lineWidth: 5 * multiplier))
                .frame(width: size * 39 / 44, height: size * 39 / 44)
            Circle()
                .trim(from: show ? progress : 1, to: 1.0)
                .stroke(LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .topTrailing, endPoint: .bottomLeading), style: StrokeStyle(lineWidth: 5 * multiplier, lineCap: .round, lineJoin: .round, miterLimit: .infinity, dash: [20, 0], dashPhase: 0))
                .rotationEffect(Angle(degrees: 90))
                .rotation3DEffect(Angle(degrees: 180), axis: (x: 1, y: 0, z: 0))
                .frame(width: size * 39 / 44, height: size * 39 / 44)
                .shadow(color: color2.opacity(0.1), radius: 3 * multiplier, x: 0, y: 3 * multiplier)
                .animation(.easeInOut(duration: 0.8), value: show)
                Image(icon.name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20 * multiplier)
                    .foregroundColor(isWhite ? .white : Color("secondary").opacity(0.5))
        }
        .frame(width: size, height: size)
    }
}

//struct RingView_Previews: PreviewProvider {
//    static var previews: some View {
//        RingView(icon: Icon.all().first!, size: 90, percent: 75, show: .constant(true))
//    }
//}
