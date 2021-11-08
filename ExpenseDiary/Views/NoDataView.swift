//
//  NoDataView.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/11/04.
//

import SwiftUI


struct NoDataView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("データがありません").style(.body).frame(maxWidth: .infinity)
            Spacer()
        }
    }
}

struct NoDataView_Previews: PreviewProvider {
    static var previews: some View {
        NoDataView()
    }
}
