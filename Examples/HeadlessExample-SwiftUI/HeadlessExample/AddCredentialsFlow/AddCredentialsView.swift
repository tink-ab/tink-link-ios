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

struct AddCredentialsView_Previews: PreviewProvider {
    static var previews: some View {
        AddCredentialsView(provider: .preview)
    }
}

extension Provider {
    static var preview = Provider(
        id: "test",
        displayName: "Test",
        authenticationUserType: .personal,
        kind: .bank,
        status: .enabled,
        credentialsKind: .password,
        helpText: nil,
        isPopular: false,
        fields: [],
        groupDisplayName: "Test",
        image: nil,
        displayDescription: "Password",
        capabilities: [.checkingAccounts],
        accessType: .openBanking,
        marketCode: "SE",
        financialInstitution: Provider.FinancialInstitution(id: "1", name: "Test")
    )
}
