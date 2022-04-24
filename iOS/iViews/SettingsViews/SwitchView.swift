//
//  SwitchView.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/23/22.
//

import SwiftUI

struct SwitchView: View {
    
    @State var switchText: String
    @Binding var switchVal: Bool
    
    var body: some View {
        Toggle("", isOn: $switchVal)
            .toggleStyle(AAToggleStyle(label: switchText))
    }
}

//struct SwitchView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwitchView()
//    }
//}
