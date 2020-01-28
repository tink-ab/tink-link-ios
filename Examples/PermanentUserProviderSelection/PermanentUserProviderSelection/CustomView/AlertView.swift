import SwiftUI

private struct AlertViewPresentationModifier<Content: View>: ViewModifier {
    @Binding var isPresented: Bool

    private let alertContent: AlertView<Content>

    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> AlertView<Content>) {
        self._isPresented = isPresented
        self.alertContent = content()
    }

    func body(content: _ViewModifier_Content<AlertViewPresentationModifier>) -> some View {
        content.overlay(
            Group {
                if isPresented {
                    ZStack(alignment: .center) {
                        Color.black.opacity(0.20)
                        alertContent
                    }
                    .edgesIgnoringSafeArea(.all)
                } else {
                    EmptyView()
                }
            }
        )
    }
}

extension View {
    func alertView<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: () -> AlertView<Content>) -> some View {
        modifier(AlertViewPresentationModifier(isPresented: isPresented, content: content))
    }
}

struct AlertView<Content: View>: View {
    var title: String

    private let content: Content
    private let dismissButton: Button?
    private let primaryButton: Button?

    private var buttons: [Button] { [dismissButton, primaryButton].compactMap({ $0 }) }

    struct Button {
        let action: () -> Void
        let label: Text
        let isEnabled: Bool
        let isPrimary: Bool

        static func `default`(_ label: Text, enabled: Bool = true, action: @escaping () -> Void = {}) -> Button {
            Button(action: action, label: label, isEnabled: enabled, isPrimary: true)
        }

        static func cancel(_ label: Text, action: @escaping () -> Void = {}) -> Button {
            Button(action: action, label: label, isEnabled: true, isPrimary: false)
        }
    }

    init(
        title: String,
        @ViewBuilder content: () -> Content,
        dismissButton: Button,
        primaryButton: Button? = nil
    ) {
        self.title = title
        self.content = content()
        self.dismissButton = dismissButton
        self.primaryButton = primaryButton
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .padding(EdgeInsets(top: 24, leading: 16, bottom: 20, trailing: 16))
                .font(.headline)
            content
            Divider()
            HStack {
                ForEach(Array(buttons.enumerated()), id: \.0) { (offset, button) in
                    Group {
                        if offset != 0 {
                            Divider()
                        }
                        SwiftUI.Button(action: button.action, label: {
                            button.label
                                .fontWeight(button.isPrimary ? .semibold : nil)
                                .frame(maxWidth: .infinity)
                        })
                            .disabled(!button.isEnabled)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(height: 44)
        }
        .frame(width: 300)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 20)
    }
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView(title: "Alert", content: {
            Text("Message text")
        }, dismissButton: .cancel(Text("Cancel")))
    }
}
