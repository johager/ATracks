//
//  LegalView.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/22/22.
//

import SwiftUI

struct LegalView: View {
    
    private let itemInfo: [[String]] = [
        ["ATracks", "The tracking information provided by ATracks is for recreational purposes, and is offered without any warranties express or implied. Avanti Applications, LLC does not guarantee the accuracy or availability of the data, and shall not be held liable for any errors in the data."],
        ["Graphics Images", "Some images are from www.flaticon.com and were designed by Smashicons."]
    ]
    
    var body: some View {
        List() {
            ForEach(0..<itemInfo.count, id: \.self) { index in
                VStack(alignment: .leading, spacing: 4) {
                    Text(itemInfo[index][0])
                        .font(.headline)
                    Text(itemInfo[index][1])
                        .font(.footnote)
                }
//                Text(itemInfo[$0][0])
//                    .font(.headline)
            }
        }
        .listStyle(.plain)
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
