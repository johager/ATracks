//
//  BlankOneMomentView.swift
//  ATracks (iOS)
//
//  Created by James Hager on 6/24/22.
//

import SwiftUI

struct BlankOneMomentView: View {
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Text("One moment please...")
                    .foregroundColor(.textInactive)
                Spacer()
            }
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

//struct BlankOneMomentView_Previews: PreviewProvider {
//    static var previews: some View {
//        BlankOneMomentView()
//    }
//}
