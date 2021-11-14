//
//  ProgressBarView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/26.
//

import SwiftUI

struct ProgressBarView: View {
    let category: Category
    let size: CGFloat
    let percent: CGFloat
    
    var progress: CGFloat {
        percent > 100 ? 1 : percent / 100
    }
    
    var multiplier: CGFloat {
        size / 44
    }
    
    var color1: Color {
        if self.percent < 70 {
            return .successDark
        } else if self.percent < 90 {
            return Color("dangerDark") 
        } else {
            return Color("warningDark")
        }
    }
    
    var color2: Color {
        if self.percent < 70 {
            return Color("successLight") 
        } else if self.percent < 90 {
            return Color("dangerLight")
        } else {
            return Color("warningLight")
        }
    }
    
    @Binding var show: Bool
    
    var body: some View {
        VStack {
            HStack (spacing: 8) {
                Image(category.icon.name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 8 * multiplier)
                    .foregroundColor(Color("darkGray"))
                Text("\(category.name)")
                    .style()
            }
            ZStack (alignment: .leading) {
                RoundedRectangle(cornerRadius: 5 * multiplier).foregroundColor(Color("secondary"))
                    .frame(width: size, height: 2.5 * multiplier)
                RoundedRectangle(cornerRadius: 5 * multiplier).fill(LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .topTrailing, endPoint: .bottomLeading))
                    //.rotation3DEffect(Angle(degrees: 180), axis: (x: 1, y: 0, z: 0))
                    .frame(width: show ? size * progress : 0, height: 2.5 * multiplier)
                    .shadow(color: color2.opacity(0.1), radius: 3 * multiplier, x: 0, y: 3 * multiplier)
                    .animation(.easeInOut(duration: 0.5))
            }
        }
    }
}

struct ProgressBarView_Previews: PreviewProvider {
    static var previews: some View {
        RingView(icon: Icon.all().first!, size: 90, percent: 75, show: .constant(true))
    }
}
