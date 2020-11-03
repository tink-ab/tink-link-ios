import SwiftUI
import TinkLink
import SDWebImageSwiftUI

struct FinancialInsititutionPicker: View {
    var financialInstitutions: [ProviderTree.FinancialInstitutionNode]

    var body: some View {
        List(financialInstitutions, id: \.financialInstitution) { financialInstitution in
            NavigationLink(destination: financialInstitution.makeDestinationView()) {
                HStack {
                    WebImage(url: financialInstitution.imageURL)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                    Text(financialInstitution.financialInstitution.name)
                }
            }
        }
        .navigationTitle("Choose Financial Institution")
    }
}

extension ProviderTree.FinancialInstitutionNode {
    @ViewBuilder
    func makeDestinationView() -> some View {
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
        }
    }
}
