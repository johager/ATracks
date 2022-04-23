//
//  NavigationLink+.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/22/22.
//
//  From https://stackoverflow.com/questions/62238852/swiftui-list-disclosure-indicator-without-navigationlink
//

import SwiftUI

extension NavigationLink where Label == EmptyView, Destination == EmptyView {

   /// Useful in cases where a `NavigationLink` is needed but there should not be
   /// a destination. e.g. for programmatic navigation.
   static var empty: NavigationLink {
       self.init(destination: EmptyView(), label: { EmptyView() })
   }
}
