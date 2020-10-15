import SwiftUI
import TinkLink

struct ProviderPicker: View {
    var providerTree: ProviderTree
    var onSelection: (Provider) -> Void

    init(providers: [Provider], onSelection: @escaping (Provider) -> Void) {
        self.providerTree = ProviderTree(providers: providers)
        self.onSelection = onSelection
    }

    var body: some View {
        NavigationView {
            FinancialInsititutionGroupPicker(financialInstitutionGroups: providerTree.financialInstitutionGroups, onSelection: onSelection)
        }
    }
}
