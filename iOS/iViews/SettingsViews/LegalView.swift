//
//  LegalView.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/22/22.
//

import SwiftUI

struct LegalView: View {
    
    // MARK: - View
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("ATracks")
                .settingsSubHeader
            Text("The tracking information provided by ATracks is for recreational purposes, and is offered without any warranties express or implied. Avanti Applications, LLC does not guarantee the accuracy or availability of the data, and shall not be held liable for any errors in the data.")
                .font(.body)
                .padding(.top, 1)
            Spacer()
        }
        .padding()
        .navigationTitle("Legal")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct LegalView_Previews: PreviewProvider {
    static var previews: some View {
        LegalView()
    }
}
