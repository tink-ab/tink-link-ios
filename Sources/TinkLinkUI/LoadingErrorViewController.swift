import UIKit

final class LoadingErrorViewController: UIViewController {
    private var onRetry: (() -> Void)?
    private var onClose: (() -> Void)?

    private let errorView = LoadingErrorView()

    init(error: Error?, onClose: @escaping () -> Void, onRetry: (() -> Void)?) {
        super.init(nibName: nil, bundle: nil)

        self.onRetry = onRetry
        self.onClose = onClose

        errorView.configure(with: error, showRetry: onRetry != nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LoadingErrorViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.background

        errorView.delegate = self

        errorView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(errorView)

        NSLayoutConstraint.activate([
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        let baseColor = (navigationController?.isNavigationBarHidden ?? true) ? Color.background : Color.navigationBarBackground
        if #available(iOS 13.0, *) {
            return baseColor.resolvedColor(with: traitCollection).isLight ? .darkContent : .lightContent
        } else {
            return baseColor.isLight ? .default : .lightContent
        }
    }
}

extension LoadingErrorViewController: LoadingErrorViewDelegate {
    func reloadProviderList(loadingErrorView: LoadingErrorView) {
        onRetry?()
    }

    func closeErrorView(loadingErrorView: LoadingErrorView) {
        onClose?()
    }
}
