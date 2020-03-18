import SwiftUI
import TinkLink

struct AddCredentialFlowView: View, UIViewControllerRepresentable {
    private var providers: [Provider]
    private var credentialController: CredentialController

    init(providers: [Provider], credentialController: CredentialController, onCompletion: @escaping CompletionHandler) {
        self.onCompletion = onCompletion
        self.providers = providers
        self.credentialController = credentialController
    }

    class Coordinator {
        let completionHandler: CompletionHandler

        init(completionHandler: @escaping CompletionHandler) {
            self.completionHandler = completionHandler
        }
    }

    typealias CompletionHandler = (Result<Credentials, Error>) -> Void
    var onCompletion: CompletionHandler

    typealias UIViewControllerType = UINavigationController

    func makeCoordinator() -> AddCredentialFlowView.Coordinator {
        return Coordinator(completionHandler: onCompletion)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<AddCredentialFlowView>) -> AddCredentialFlowView.UIViewControllerType {
        guard let credentialContext = credentialController.credentialContext else {fatalError("Should set up the credential context first")}
        let viewController = ProviderListViewController(providers: providers, credentialContext: credentialContext, style: .plain)
        viewController.onCompletion = context.coordinator.completionHandler
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.prefersLargeTitles = true
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<AddCredentialFlowView>) {
        // NOOP
    }
}

struct ProviderFlowView_Previews: PreviewProvider {
    static var previews: some View {
        AddCredentialFlowView(providers: [], credentialController: CredentialController(), onCompletion: { _ in })
    }
}
