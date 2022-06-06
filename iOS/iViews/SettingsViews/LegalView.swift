//
//  LegalView.swift
//  ATracks (iOS)
//
//  Created by James Hager on 4/22/22.
//

import SwiftUI

struct LegalView: View {
    
    @Binding private var isShowingLegal: Bool
    
    // MARK: - Init
    
    init(isShowingLegal: Binding<Bool> = .constant(false)) {
        _isShowingLegal = isShowingLegal
    }
    
    // MARK: - View
    
    var body: some View {
        ZStack {
            List {
                Group {
                    Text("ATracks")
                        .settingsSubHeader
                    Text("The tracking information provided by ATracks is for recreational purposes, and is offered without any warranties express or implied. Avanti Applications, LLC does not guarantee the accuracy or availability of the data, and shall not be held liable for any errors in the data.")
                        .font(.body)
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .padding(.top, isShowingLegal ? 40 : 6)
            
            if isShowingLegal {
                VStack {
                    ZStack {
                        Text("Legal")
                            .settingsSubHeader
                        HStack {
                            Spacer()
                            Button {
                                isShowingLegal = false
                            } label: {
                                Image(systemName: "xmark.circle")
                                    .font(.title)
                                    .tint(.textSelectable)
                            }
                        }
                    }
                    Spacer()
                }
                .padding([.top, .trailing], 6)
            }
        }
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
