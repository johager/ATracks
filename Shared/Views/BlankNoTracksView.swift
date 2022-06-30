//
//  BlankNoTracksView.swift
//  ATracks
//
//  Created by James Hager on 4/28/22.
//

import SwiftUI

struct BlankNoTracksView: View {
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                VStack {
                    Text("There are no tracks.")
                        .font(.headline)
                    #if os(iOS)
                    if geometry.isLandscape {
                        Text("Create a track by clicking on the Start button,\nor create a track on your iPhone or iPod Touch.")
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                    } else {
                        Text("Select Tracks and then Start tracking,\nor create a track on your iPhone or iPod Touch.")
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                    }
                    #else
                    Text("Tracks can only be created on an iPhone, iPad, or iPod Touch.")
                        .padding(.top, 8)
                    #endif
                }
                Spacer()
            }
            #if os(iOS)
            .padding(.top, geometry.size.height * 0.2)
            #else
            .padding(.top, geometry.size.height / 3)
            #endif
        }
        #if os(iOS)
        .ignoresSafeArea(.keyboard)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct BlankView_Previews: PreviewProvider {
    static var previews: some View {
        BlankNoTracksView()
    }
}
