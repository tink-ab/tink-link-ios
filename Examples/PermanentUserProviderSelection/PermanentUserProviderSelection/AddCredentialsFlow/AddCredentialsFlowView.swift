import SwiftUI
import TinkLink

struct AddCredentialsFlowView: View, UIViewControllerRepresentable {
    private var providers: [Provider]
    private var credentialsController: CredentialsController

    init(providers: [Provider], credentialsController: CredentialsController, onCompletion: @escaping CompletionHandler) {
        self.onCompletion = onCompletion
        self.providers = providers
        self.credentialsController = credentialsController
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

    func makeCoordinator() -> AddCredentialsFlowView.Coordinator {
        return Coordinator(completionHandler: onCompletion)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<AddCredentialsFlowView>) -> AddCredentialsFlowView.UIViewControllerType {
        let credentialsContext = credentialsController.credentialsContext
        let viewController = ProviderListViewController(providers: providers, credentialsContext: credentialsContext, style: .plain)
        viewController.onCompletion = context.coordinator.completionHandler
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.prefersLargeTitles = true
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<AddCredentialsFlowView>) {
        // NOOP
    }
}

struct ProviderFlowView_Previews: PreviewProvider {
    static var previews: some View {
        AddCredentialsFlowView(providers: [], credentialsController: CredentialsController(), onCompletion: { _ in })
    }
}
