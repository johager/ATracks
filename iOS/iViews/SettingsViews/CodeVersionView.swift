//
//  CodeVersionView.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/19/22.
//

import SwiftUI

struct CodeVersionView: View, Identifiable {
    var id = "codeVersionView"
    
    var body: some View {
        Text("\(AppInfo.appNameWithFullVersion)\n© \(AppInfo.copyrightYear) Avanti Applications, LLC")
            .font(.footnote)
            .padding([.top, .bottom], 8)
    }
}

//struct CodeVersionView_Previews: PreviewProvider {
//    static var previews: some View {
//        CodeVersionView()
//    }
//}
