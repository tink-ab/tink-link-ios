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
