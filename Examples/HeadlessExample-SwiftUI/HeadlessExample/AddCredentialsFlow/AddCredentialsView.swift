import SwiftUI
import TinkLink

struct AddCredentialsView: View {
    var provider: Provider
    @State private var form: TinkLink.Form

    @EnvironmentObject var credentialsController: CredentialsController
    @SwiftUI.Environment(\.presentationMode) var presentationMode

    init(provider: Provider) {
        self.provider = provider
        self._form = State(initialValue: TinkLink.Form(provider: provider))
    }

    var body: some View {
        EmptyView()
    }
}
