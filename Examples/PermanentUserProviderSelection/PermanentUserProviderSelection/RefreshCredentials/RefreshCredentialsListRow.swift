import SwiftUI
import TinkLink

struct RefreshCredentialsListRow: View {
    enum ViewState {
        case selection
        case updating
        case updated
        case error
    }

    var provider: Provider?
    var viewState: ViewState
    @Binding private(set) var isSelected: Bool

    @State private var isAnimating: Bool = false

    var body: some View {
        return Group {
            if viewState == .selection {
                Toggle(isOn: $isSelected) {
                    Text(provider?.displayName ?? "")
                }
            } else if viewState == .updating {
                HStack {
                    Text(provider?.displayName ?? "")
                    Spacer()
                    ActivityIndicator(isAnimating: $isAnimating, style: .medium)
                        .onAppear { self.isAnimating = true }
                        .onDisappear { self.isAnimating = false }
                        .frame(width: 20, height: 20, alignment: .trailing)
                }
                .frame(idealHeight: 30)
            }
            else if viewState == .updated {
                HStack {
                    Text(provider?.displayName ?? "")
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                .frame(idealHeight: 30)
            }
            else {
                HStack {
                    Text(provider?.displayName ?? "")
                    Spacer()
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                }
                .frame(idealHeight: 30)
            }
        }
    }
}
