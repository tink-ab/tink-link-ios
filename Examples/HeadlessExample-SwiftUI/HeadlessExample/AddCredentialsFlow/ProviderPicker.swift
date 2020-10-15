import SwiftUI
import TinkLink

struct ProviderPicker: View {
    var providerTree: ProviderTree
    var onCompletion: (Provider) -> Void

    init(providers: [Provider], onCompletion: @escaping (Provider) -> Void) {
        self.providerTree = ProviderTree(providers: providers)
        self.onCompletion = onCompletion
    }

    var body: some View {
        NavigationView {
            FinancialInsititutionGroupPicker(financialInstitutionGroups: providerTree.financialInstitutionGroups, onCompletion: onCompletion)
                .navigationBarTitle("Choose Bank", displayMode: .inline)
        }
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

func destinationView(for financialInstitution: ProviderTree.FinancialInstitutionNode) -> some View {
    return Group {
        switch financialInstitution {
        case .provider(let provider):
            Text(provider.displayName)
        case .credentialsKinds(let credentialsKinds):
            CredentialsKindPicker(credentialsKinds: credentialsKinds)
        case .accessTypes(let accessTypes):
            AccessTypePicker(accessTypes: accessTypes)
        case .authenticationUserTypes(let authenticationUserTypes):
            AuthenticationUserTypePicker(authenticationUserTypes: authenticationUserTypes)
        }
    }
}

func destinationView(for authenticationUserType: ProviderTree.AuthenticationUserTypeNode) -> some View {
    return Group {
        switch authenticationUserType {
        case .provider(let provider):
            Text(provider.displayName)
        case .credentialsKinds(let credentialsKinds):
            CredentialsKindPicker(credentialsKinds: credentialsKinds)
        case .accessTypes(let accessTypes):
            AccessTypePicker(accessTypes: accessTypes)
        }
    }
}

func destinationView(for accessType: ProviderTree.AccessTypeNode) -> some View {
    return Group {
        switch accessType {
        case .provider(let provider):
            Text(provider.displayName)
        case .credentialsKinds(let credentialsKinds):
            CredentialsKindPicker(credentialsKinds: credentialsKinds)
        }
    }
}

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

// TODO: Move this to Core
extension ProviderTree.AuthenticationUserTypeNode: Identifiable {
    public var id: String {
        switch authenticationUserType {
        case .personal: return "personal"
        case .business: return "business"
        case .corporate: return "corporate"
        case .unknown: return "unknown"
        }
    }
}

struct AuthenticationUserTypePicker: View {
    var authenticationUserTypes: [ProviderTree.AuthenticationUserTypeNode]

    var body: some View {
        List(authenticationUserTypes, id: \.id) { authenticationUserType in
            NavigationLink(destination: destinationView(for: authenticationUserType)) {
                AuthenticationUserTypeRow(authenticationUserType: authenticationUserType.authenticationUserType)
            }
        }
        .navigationTitle("Choose Authentication Type")
    }
}

struct AuthenticationUserTypeRow: View {
    var authenticationUserType: Provider.AuthenticationUserType

    var body: some View {
        switch authenticationUserType {
        case .personal:
            Text("Personal")
        case .business:
            Text("Business")
        case .corporate:
            Text("Corporate")
        case .unknown:
            Text("Unknown")
        }
    }
}

struct AccessTypePicker: View {
    var accessTypes: [ProviderTree.AccessTypeNode]

    var body: some View {
        List(accessTypes, id: \.id) { accessType in
            NavigationLink(destination: destinationView(for: accessType)) {
                switch accessType.accessType {
                case .openBanking:
                    Text("Open Banking")
                case .other:
                    Text("Other")
                case .unknown:
                    Text("Unknown")
                }
            }
        }
        .navigationTitle("Choose Access Type")
    }
}

struct CredentialsKindPicker: View {
    var credentialsKinds: [ProviderTree.CredentialsKindNode]

    var body: some View {
        List(credentialsKinds, id: \.id) { credentialsKind in
            NavigationLink(destination: Text(credentialsKind.provider.displayName)) {
                switch credentialsKind.credentialsKind {
                case .password:
                    Text("Password")
                case .mobileBankID:
                    Text("Mobile BankID")
                case .thirdPartyAuthentication:
                    Text("Third Party Authentication")
                case .keyfob:
                    Text("Key Fob")
                case .fraud:
                    Text("Fraud")
                case .unknown:
                    Text("Unknown")
                }
            }
        }
        .navigationTitle("Choose Credentials Type")
    }
}
