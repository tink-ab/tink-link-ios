import SwiftUI
import TinkLink
import SDWebImageSwiftUI

struct FinancialInsititutionGroupPicker: View {
    var financialInstitutionGroups: [ProviderTree.FinancialInstitutionGroupNode]

    var body: some View {
        List(financialInstitutionGroups) { financialInstitutionGroup in
            NavigationLink(destination: financialInstitutionGroup.destinationView()) {
                HStack {
                    WebImage(url: financialInstitutionGroup.imageURL)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                    Text(financialInstitutionGroup.displayName)
                }
            }
        }
        .navigationBarTitle("Choose Bank", displayMode: .inline)
    }
}

extension ProviderTree.FinancialInstitutionGroupNode {
    @ViewBuilder
    func destinationView() -> some View {
        switch self {
        case .provider(let provider):
            AddCredentialsView(provider: provider)
                .navigationTitle(provider.displayName)
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
