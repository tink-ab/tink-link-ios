import SwiftUI
import TinkLink

struct ContentView: View {
    var body: some View {
        NavigationView {
            CredentialsList()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
