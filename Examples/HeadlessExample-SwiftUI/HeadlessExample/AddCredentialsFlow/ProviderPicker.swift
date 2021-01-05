import SwiftUI
import TinkLink

struct ProviderPicker: View {
    var providerTree: ProviderTree

    @SwiftUI.Environment(\.presentationMode) var presentationMode

    init(providers: [Provider]) {
        self.providerTree = ProviderTree(providers: providers)
    }

    var body: some View {
        NavigationView {
            FinancialInsititutionGroupPicker(financialInstitutionGroups: providerTree.financialInstitutionGroups)
                .toolbar(content: {
                    ToolbarItem(id: "Cancel", placement: .cancellationAction) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                })
        }
        .listStyle(PlainListStyle())
    }
}
