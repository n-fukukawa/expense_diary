//
//  MyEditButton.swift
//  ExpenseDiary
//
//  Created by Naruki Fukukawa on 2021/10/29.
//

import SwiftUI

struct MyEditButton: View {
    @Environment(\.editMode) var editMode
    
    var body: some View {
        Button(action: {
            withAnimation {
                if editMode?.wrappedValue.isEditing == true {
                    editMode?.wrappedValue = .inactive
                } else {
                    editMode?.wrappedValue = .active
                }
            }
        }) {
            Text(editMode?.wrappedValue.isEditing == true ? "完了" : "編集")
        }
    }
}
