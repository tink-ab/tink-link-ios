import Foundation
import TinkLinkSDK

protocol AddCredentialFlowNavigating: AnyObject {
    func showFinancialInstitution(for financialInstitutionNodes: [ProviderTree.FinancialInstitutionNode], title: String?)
    func showAccessTypePicker(for accessTypeNodes: [ProviderTree.AccessTypeNode], title: String?)
    func showCredentialKindPicker(for credentialKindNodes: [ProviderTree.CredentialKindNode], title: String?)
    func showAddCredential(for provider: Provider)
    func showScopeDescriptions()
    func showTermsAndConditions()
    func showPrivacyPolicy()
}
