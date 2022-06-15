//
//  OnboardingView.swift
//  ATracks (macOS)
//
//  Created by James Hager on 6/15/22.
//

import SwiftUI

struct OnboardingView: View {
    
    @Binding private var isOnboarding: Bool
    
    let sections: [SectionData] = [
        SectionData(title: "About", textArray: AboutHelper.introText, paddingTop: 0),
        SectionData(title: "Search", textArray: AboutHelper.searchText, paddingTop: 16),
        SectionData(title: "Display", textArray: AboutHelper.displayText, paddingTop: 16)
    ]
    
    struct SectionData: Identifiable {
        let id = UUID().uuidString
        let title: String
        let textArray: [String]
        let paddingTop: CGFloat
    }
    
    // MARK: - Init
    
    init(isOnboarding: Binding<Bool> = .constant(false)) {
        _isOnboarding = isOnboarding
        OnboardingHelper.setHasOnboarded()
    }
    
    // MARK: - View
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Welcome to ATracks!")
                    .settingsSubHeader
                Spacer()
            }
            
            List {
                ForEach(sections) { section in
                    Section {
                        ForEach(0..<section.textArray.count, id: \.self) { index in
                            Text(stringToDisplay(from: section.textArray[index]))
                                .padding(.top, 8)
                        }
                    } header: {
                        Text(section.title)
                            .settingsHeader
                            .padding(.top, section.paddingTop)
                    }
                }
                .padding(.trailing, 4)
            }
            .listStyle(.plain)
            
            HStack {
                Spacer()
                Button("OK") {
                    isOnboarding = false
                }
                Spacer()
            }
        }
        
        .frame(width: 555, height: 330)
        .padding()
        .background(Color.background)
    }
    
    // MARK: - Methods
    
    func stringToDisplay(from string: String) -> String {
        return string.replacingOccurrences(of: "Touch or swipe", with: "Click or drag")
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
