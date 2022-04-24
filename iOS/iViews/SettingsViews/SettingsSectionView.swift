//
//  SettingsSectionView.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/24/22.
//

import SwiftUI

struct SettingsSectionView: View {
    
    @State var title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title3)
//                .bold()
                .foregroundColor(.headerText)
//                .kerning(1)
//                .textCase(.uppercase)
                
            Spacer()
        }
        .listRowBackground(
            ZStack {
                Color.headerBorder
                Rectangle()
                    .fill(Color.headerBackground)
                    .padding([.top, .bottom], 1)
            }
                .edgesIgnoringSafeArea(.all)
                )
        .listRowSeparator(.hidden)
    }
}

struct SettingsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSectionView(title: "Section Title")
    }
}
