import SwiftUI
import TinkLink

struct SupplementControllerRepresentableView: View, UIViewControllerRepresentable {
    private var supplementInformationTask: SupplementInformationTask

    init(supplementInformationTask: SupplementInformationTask, onCompletion: @escaping CompletionHandler) {
        self.supplementInformationTask = supplementInformationTask
        self.onCompletion = onCompletion
    }

    class Coordinator {
        let completionHandler: CompletionHandler

        init(completionHandler: @escaping CompletionHandler) {
            self.completionHandler = completionHandler
        }
    }

    typealias CompletionHandler = (Result<Void, Error>) -> Void
    var onCompletion: CompletionHandler

    typealias UIViewControllerType = UINavigationController

    func makeCoordinator() -> SupplementControllerRepresentableView.Coordinator {
        return Coordinator(completionHandler: onCompletion)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<SupplementControllerRepresentableView>) -> SupplementControllerRepresentableView.UIViewControllerType {
        let viewController = SupplementalInformationViewController(supplementInformationTask: supplementInformationTask)
        viewController.onCompletion = context.coordinator.completionHandler
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.prefersLargeTitles = true
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<SupplementControllerRepresentableView>) {
        // NOOP
    }
}
