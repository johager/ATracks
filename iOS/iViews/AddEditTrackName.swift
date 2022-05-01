//
//  AddEditTrackName.swift
//  ATracks (iOS)
//
//  Created by James Hager on 5/1/22.
//
//  Based on https://stackoverflow.com/questions/56726663/how-to-add-a-textfield-to-alert-in-swiftui
//  and https://gist.github.com/chriseidhof/cb662d2161a59a0cd5babf78e3562272
//

import SwiftUI

class TrackNameAlertViewController: UIViewController {
    
    // MARK: - Properties
    
    let alertTitle: Binding<String>
    let message: Binding<String?>
    let text: Binding<String?>
    let doneTitle: Binding<String>
    var isPresented: Binding<Bool>?
    let completion: (String?) -> ()
    
    init(title: Binding<String>, message: Binding<String?>, text: Binding<String?>, doneTitle: Binding<String>, isPresented: Binding<Bool>?, completion: @escaping (String?) -> ()) {
        self.alertTitle = title
        self.message = message
        self.text = text
        self.doneTitle = doneTitle
        self.isPresented = isPresented
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentAlertController()
    }
    
    // MARK: - Methods
    
    private func presentAlertController() {
        
        let alert = UIAlertController(title: alertTitle.wrappedValue, message: message.wrappedValue, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = self.text.wrappedValue
            textField.placeholder = "Track name..."
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
            textField.clearButtonMode = .always
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.complete(with: nil)
        }
        
        let apply = UIAlertAction(title: doneTitle.wrappedValue, style: .default) { _ in
            guard let text = alert.textFields?.first?.text
            else { return self.complete(with: "") }
            
            self.complete(with: text)
        }
        
        alert.addAction(cancel)
        alert.addAction(apply)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func complete(with text: String?) {
        completion(text)
        isPresented?.wrappedValue = false
    }
}

struct TrackNameAlert {
    
    // MARK: Properties
    let title: Binding<String>
    let message: Binding<String?>
    var text: Binding<String?>
    var doneTitle: Binding<String>
    var isPresented: Binding<Bool>? = nil
    var completion: (String?) -> ()
    
    // MARK: Modifiers
    func dismissable(_ isPresented: Binding<Bool>) -> TrackNameAlert {
        TrackNameAlert(title: title, message: message, text: text, doneTitle: doneTitle, isPresented: isPresented, completion: completion)
    }
}

extension TrackNameAlert: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = TrackNameAlertViewController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<TrackNameAlert>) -> UIViewControllerType {
        TrackNameAlertViewController(title: title, message: message, text: text, doneTitle: doneTitle, isPresented: isPresented, completion: completion)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<TrackNameAlert>) {
        // no update needed
    }
}

struct TrackNameAlertWrapper<PresentingView: View>: View {
    
    @Binding var isPresented: Bool
    let presentingView: PresentingView
    let content: () -> TrackNameAlert
    
    var body: some View {
        ZStack {
            if isPresented {
                content().dismissable($isPresented)
            }
            presentingView
        }
    }
}

extension View {
    func trackNameAlert(isPresented: Binding<Bool>, content: @escaping () -> TrackNameAlert) -> some View {
        TrackNameAlertWrapper(isPresented: isPresented, presentingView: self, content: content)
    }
}
