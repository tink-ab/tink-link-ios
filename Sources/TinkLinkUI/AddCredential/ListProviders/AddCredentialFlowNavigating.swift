import Foundation
import TinkLink

protocol AddCredentialFlowNavigating: AnyObject {
    func showFinancialInstitution(for financialInstitutionNodes: [ProviderTree.FinancialInstitutionNode], title: String?)
    func showAccessTypePicker(for accessTypeNodes: [ProviderTree.AccessTypeNode], title: String?)
    func showCredentialKindPicker(for credentialKindNodes: [ProviderTree.CredentialKindNode], title: String?)
    func showAddCredential(for provider: Provider)
    func showScopeDescriptions()
    func showWebContent(with url: URL)
    func showAddCredentialSuccess()
}
