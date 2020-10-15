import SwiftUI
import TinkLink

struct FinancialInsititutionPicker: View {
    var financialInstitutions: [ProviderTree.FinancialInstitutionNode]

    var body: some View {
        List(financialInstitutions, id: \.financialInstitution) { financialInstitution in
            NavigationLink(destination: destinationView(for: financialInstitution)) {
                Text(financialInstitution.financialInstitution.name)
            }
        }
        .navigationTitle("Choose Financial Institution")
    }
}

struct FinancialInsititutionPicker_Previews: PreviewProvider {
    static var previews: some View {
        FinancialInsititutionPicker(financialInstitutions: [])
    }
}

@ViewBuilder
func destinationView(for financialInstitution: ProviderTree.FinancialInstitutionNode) -> some View {
    switch financialInstitution {
    case .provider(let provider):
        AddCredentialsView(provider: provider)
    case .credentialsKinds(let credentialsKinds):
        CredentialsKindPicker(credentialsKinds: credentialsKinds)
    case .accessTypes(let accessTypes):
        AccessTypePicker(accessTypes: accessTypes)
    case .authenticationUserTypes(let authenticationUserTypes):
        AuthenticationUserTypePicker(authenticationUserTypes: authenticationUserTypes)
    }
}
