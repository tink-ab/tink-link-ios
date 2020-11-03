import SwiftUI
import TinkLink

struct ProviderPicker: View {
    var providerTree: ProviderTree

    init(providers: [Provider]) {
        self.providerTree = ProviderTree(providers: providers)
    }

    var body: some View {
        NavigationView {
            FinancialInsititutionGroupPicker(financialInstitutionGroups: providerTree.financialInstitutionGroups)
        }
        .listStyle(PlainListStyle())
    }
}
