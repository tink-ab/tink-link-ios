import SwiftUI
import TinkLink

struct FinancialInsititutionGroupPicker: View {
    var financialInstitutionGroups: [ProviderTree.FinancialInstitutionGroupNode]
    var onCompletion: (Provider) -> Void

    var body: some View {
        List(financialInstitutionGroups) { financialInstitutionGroup in
            NavigationLink(destination: destinationView(for: financialInstitutionGroup)) {
                Text(financialInstitutionGroup.displayName)
            }
        }
    }
}

struct FinancialInsititutionGroupPicker_Previews: PreviewProvider {
    static var previews: some View {
        FinancialInsititutionGroupPicker(financialInstitutionGroups: []) { _ in }
    }
}

func destinationView(for financialInstitutionGroup: ProviderTree.FinancialInstitutionGroupNode) -> some View {
    return Group {
        switch financialInstitutionGroup {
        case .provider(let provider):
            Text(provider.displayName)
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
}
