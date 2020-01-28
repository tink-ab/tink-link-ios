import UIKit
import TinkLinkSDK

final class RefreshCredentialViewController: UIViewController {

    struct ViewModel {
        var credential: Credential
        enum ViewState {
            case selection(Bool)
            case updating
            case updated
            case error
        }

        var viewState: ViewState
    }

    private let refreshCredentialList = SelfSizingTableView()
    private let titleLabel = UILabel()
    private let dismissButton = UIButton(type: .system)
    private let primiaryButton = UIButton(type: .system)
    private let stackView = UIStackView()
    private let contentView = UIView()

    private let titleText: String
    private let dismissAction: (UIViewController) -> Void
    private let primaryAction: (([Credential]) -> Void)?
    private let verticalSeparator = UIView()
    private var primaryButtonConstraints = [NSLayoutConstraint]()

    private var credentialController: CredentialController
    private var providerController: ProviderController

    private var credentialsToRefresh: [Credential]
    private var viewModels: [ViewModel] {
        didSet {
            let credentials = viewModels.filter {
                switch $0.viewState {
                case .selection(let selected):
                    return selected
                default:
                    return false
                }
            }.map { $0.credential }
            credentialsToRefresh = credentials
            DispatchQueue.main.async {
                self.refreshCredentialList.reloadData()
            }
        }
    }

    init(titleText: String, credentialController: CredentialController, providerController: ProviderController, dismissAction: @escaping (UIViewController) -> Void, primaryAction: (([Credential]) -> Void)?) {
        self.titleText = titleText
        self.viewModels = credentialController.credentials.map{ ViewModel(credential: $0, viewState: .selection(true)) }
        self.credentialsToRefresh = credentialController.credentials
        self.credentialController = credentialController
        self.providerController = providerController
        self.dismissAction = dismissAction
        self.primaryAction = primaryAction

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(credentialRefresing), name: .credentialControllerDidUpdateStatus, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(credentialsFinishedRefresh), name: .credentialControllerDidFinishRefreshingCredentials, object: nil)

        setup()
    }

    func setup() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.addSubview(blurEffectView)

        titleLabel.text = titleText
        titleLabel.font = .preferredFont(forTextStyle: .headline)

        refreshCredentialList.dataSource = self
        refreshCredentialList.delegate = self
        refreshCredentialList.separatorStyle = .none
        refreshCredentialList.translatesAutoresizingMaskIntoConstraints = false
        refreshCredentialList.rowHeight = UITableView.automaticDimension
        refreshCredentialList.estimatedRowHeight = 52
        refreshCredentialList.isScrollEnabled = false
        refreshCredentialList.alwaysBounceVertical = false
        refreshCredentialList.register(FixedImageSizeTableViewCell.self, forCellReuseIdentifier: "cell")

        let horizontalStackView = UIStackView()
        horizontalStackView.alignment = .center
        horizontalStackView.distribution = .fill
        dismissButton.setTitle("Cancel", for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissActionPressed), for: .touchUpInside)
        dismissButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        dismissButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        horizontalStackView.addArrangedSubview(dismissButton)
        primaryAction.flatMap { _ in
            primiaryButton.addTarget(self, action: #selector(primaryActionPressed), for: .touchUpInside)
            primiaryButton.setTitle("Update", for: .normal)
            primiaryButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
            primiaryButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
            verticalSeparator.translatesAutoresizingMaskIntoConstraints = false
            verticalSeparator.backgroundColor = .separator
            horizontalStackView.addArrangedSubview(verticalSeparator)
            horizontalStackView.addArrangedSubview(primiaryButton)
            primaryButtonConstraints = [
                primiaryButton.widthAnchor.constraint(equalTo: dismissButton.widthAnchor),
                verticalSeparator.widthAnchor.constraint(equalToConstant: 1),
                verticalSeparator.heightAnchor.constraint(equalTo: horizontalStackView.heightAnchor)
            ]
            NSLayoutConstraint.activate(primaryButtonConstraints)
        }
        let horizontalSeparator = UIView()
        horizontalSeparator.translatesAutoresizingMaskIntoConstraints = false
        horizontalSeparator.backgroundColor = .separator

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(refreshCredentialList)
        stackView.addArrangedSubview(horizontalSeparator)
        stackView.addArrangedSubview(horizontalStackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.setCustomSpacing(0, after: horizontalSeparator)

        contentView.backgroundColor = .white
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.cornerRadius = 15
        contentView.layer.masksToBounds = true

        contentView.addSubview(stackView)
        view.addSubview(contentView)

        NSLayoutConstraint.activate([
            horizontalSeparator.heightAnchor.constraint(equalToConstant: 1),
            horizontalSeparator.widthAnchor.constraint(equalTo: stackView.widthAnchor),

            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            refreshCredentialList.widthAnchor.constraint(equalToConstant: 300),
            horizontalStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    @objc private func credentialRefresing(notification: Notification) {
        DispatchQueue.main.async {
            if let userInfo = notification.userInfo as? [String: Credential], let credential = userInfo["credential"] {
                if let index = self.viewModels.firstIndex(where: { credential.id == $0.credential.id }) {
                    if credential.status == .updating {
                        self.viewModels[index] = ViewModel(credential: credential, viewState: .updating)
                    } else if credential.status == .updated {
                        self.viewModels[index] = ViewModel(credential: credential, viewState: .updated)
                    }
                }
            }
        }
    }

    @objc private func credentialsFinishedRefresh() {
        DispatchQueue.main.async {
            self.dismiss(animated: false)
        }
    }

    @objc private func dismissActionPressed(sender: UIButton) {
        dismissAction(self)
    }

    @objc private func primaryActionPressed(sender: UIButton) {
        refreshCredentialList.isUserInteractionEnabled = false
        primaryButtonConstraints.forEach { $0.isActive = false }
        primiaryButton.removeFromSuperview()
        verticalSeparator.removeFromSuperview()
        primaryAction?(credentialsToRefresh)
    }
}

extension RefreshCredentialViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FixedImageSizeTableViewCell
        let viewModel = viewModels[indexPath.item]
        configure(cell, viewModel: viewModel)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = viewModels[indexPath.item]
        switch viewModel.viewState {
        case .selection(let selected):
            viewModels[indexPath.item].viewState = .selection(!selected)
        default:
            break
        }
    }

    private func configure(_ cell: FixedImageSizeTableViewCell, viewModel: ViewModel) {
        let provider = providerController.provider(providerID: viewModel.credential.providerID)
        cell.setTitle(text: provider?.displayName ?? viewModel.credential.kind.description)
        provider?.image.flatMap{ cell.setImage(url: $0) }

        switch viewModel.viewState {
        case .selection(let selected):
            let switchView = UISwitch()
            switchView.isUserInteractionEnabled = false
            switchView.isOn = selected
            cell.accessoryView = switchView
        case .updating:
            let activityIndicatorView = UIActivityIndicatorView(style: .medium)
            cell.accessoryView = activityIndicatorView
            activityIndicatorView.startAnimating()
        case .updated:
            cell.accessoryView = nil
            cell.accessoryType = .checkmark
        case .error:
            break
        }
    }
}
