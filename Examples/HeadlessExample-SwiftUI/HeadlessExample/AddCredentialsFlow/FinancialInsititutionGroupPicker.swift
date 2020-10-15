import SwiftUI
import TinkLink

struct FinancialInsititutionGroupPicker: View {
    var financialInstitutionGroups: [ProviderTree.FinancialInstitutionGroupNode]

    var body: some View {
        List(financialInstitutionGroups) { financialInstitutionGroup in
            NavigationLink(destination: destinationView(for: financialInstitutionGroup)) {
                Text(financialInstitutionGroup.displayName)
            }
        }
        .navigationBarTitle("Choose Bank", displayMode: .inline)
    }
}

struct FinancialInsititutionGroupPicker_Previews: PreviewProvider {
    static var previews: some View {
        FinancialInsititutionGroupPicker(financialInstitutionGroups: [])
    }
}

@ViewBuilder
func destinationView(for financialInstitutionGroup: ProviderTree.FinancialInstitutionGroupNode) -> some View {
    switch financialInstitutionGroup {
    case .provider(let provider):
        AddCredentialsView(provider: provider)
    case .credentialsKinds(let credentialsKinds):
        CredentialsKindPicker(credentialsKinds: credentialsKinds)
    case .accessTypes(let accessTypes):
        AccessTypePicker(accessTypes: accessTypes)
    case .authenticationUserTypes(let authenticationUserTypes):
        AuthenticationUserTypePicker(authenticationUserTypes: authenticationUserTypes)
    case .financialInstitutions(let financialInstitutions):
        FinancialInsititutionPicker(financialInstitutions: financialInstitutions)
    }
}
