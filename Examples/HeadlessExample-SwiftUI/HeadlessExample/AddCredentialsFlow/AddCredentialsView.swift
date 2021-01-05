import SwiftUI
import TinkLink

struct AddCredentialsView: View {
    var provider: Provider

    @EnvironmentObject var credentialsController: CredentialsController
    @SwiftUI.Environment(\.presentationMode) var presentationMode

    var body: some View {
        EmptyView()
    }
}
