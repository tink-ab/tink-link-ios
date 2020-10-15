import SwiftUI
import TinkLink

struct FinancialInsititutionGroupPicker: View {
    var financialInstitutionGroups: [ProviderTree.FinancialInstitutionGroupNode]
    var onSelection: (Provider) -> Void

    var body: some View {
        List(financialInstitutionGroups) { financialInstitutionGroup in
            NavigationLink(destination: destinationView(for: financialInstitutionGroup, onSelection: onSelection)) {
                Text(financialInstitutionGroup.displayName)
            }
        }
        .navigationBarTitle("Choose Bank", displayMode: .inline)
    }
}

struct FinancialInsititutionGroupPicker_Previews: PreviewProvider {
    static var previews: some View {
        FinancialInsititutionGroupPicker(financialInstitutionGroups: []) { _ in }
    }
}

@ViewBuilder
func destinationView(for financialInstitutionGroup: ProviderTree.FinancialInstitutionGroupNode, onSelection: @escaping (Provider) -> Void) -> some View {
    switch financialInstitutionGroup {
    case .provider(let provider):
        Button(action: { onSelection(provider) }) {
            Text(provider.displayName)
        }
    case .credentialsKinds(let credentialsKinds):
        CredentialsKindPicker(credentialsKinds: credentialsKinds)
    case .accessTypes(let accessTypes):
        AccessTypePicker(accessTypes: accessTypes, onSelection: onSelection)
    case .authenticationUserTypes(let authenticationUserTypes):
        AuthenticationUserTypePicker(authenticationUserTypes: authenticationUserTypes, onSelection: onSelection)
    case .financialInstitutions(let financialInstitutions):
        FinancialInsititutionPicker(financialInstitutions: financialInstitutions, onSelection: onSelection)
    }
}
