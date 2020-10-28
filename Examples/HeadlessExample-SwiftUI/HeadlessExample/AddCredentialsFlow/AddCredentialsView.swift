import SwiftUI
import TinkLink

struct AddCredentialsView: View {
    var provider: Provider

    var body: some View {
        Text(provider.displayName)
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
