import SwiftUI
import TinkLink

struct AddCredentialsView: View, UIViewControllerRepresentable {
    var provider: Provider

    @EnvironmentObject var credentialsController: CredentialsController
    @SwiftUI.Environment(\.presentationMode) var presentationMode

    class Coordinator {}

    func makeCoordinator() -> AddCredentialsView.Coordinator {
        return Coordinator()
    }

    typealias UIViewControllerType = AddCredentialsViewController

    func makeUIViewController(context: Context) -> AddCredentialsView.UIViewControllerType {
        let credentialsContext = credentialsController.credentialsContext
        let viewController = AddCredentialsViewController(provider: provider, credentialsContext: credentialsContext)
        viewController.onCompletion = { credentials in
            self.presentationMode.wrappedValue.dismiss()
        }
        return viewController
    }

    func updateUIViewController(_ uiViewController: AddCredentialsView.UIViewControllerType, context: Context) {
        // NOOP
    }
}
