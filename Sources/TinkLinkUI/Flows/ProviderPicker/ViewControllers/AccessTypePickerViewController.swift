import TinkLink
import UIKit

/// Example of how to use the provider grouped by access type
final class AccessTypePickerViewController: UITableViewController {
    private let headerView = AccessTypePickerHeaderView()
    private let tinkLinkTracker: TinkLinkTracker
    weak var providerPickerCoordinator: ProviderPickerCoordinating?

    let accessTypeNodes: [ProviderTree.AccessTypeNode]
    let capabilityFormatter = ProviderCapabilityFormatter()

    init(accessTypeNodes: [ProviderTree.AccessTypeNode], tinkLinkTracker: TinkLinkTracker) {
        self.accessTypeNodes = accessTypeNodes
        self.tinkLinkTracker = tinkLinkTracker
        super.init(style: .plain)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension AccessTypePickerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never

        let headerHeight = headerView.systemLayoutSizeFitting(CGSize(width: 320.0, height: .greatestFiniteMagnitude), withHorizontalFittingPriority: .required, verticalFittingPriority: .init(249)).height
        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: headerHeight)

        tableView.tableHeaderView = headerView

        tableView.registerReusableCell(ofType: ProviderCell.self)
        tableView.tableFooterView = UIView(frame: .zero)

        tableView.backgroundColor = Color.background
        tableView.separatorColor = Color.separator
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let headerHeight = headerView.systemLayoutSizeFitting(CGSize(width: view.frame.width, height: .greatestFiniteMagnitude), withHorizontalFittingPriority: .required, verticalFittingPriority: .init(249)).height
        var frame = headerView.frame
        frame.size.height = headerHeight
        tableView.tableHeaderView?.frame = frame
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            tinkLinkTracker.track(interaction: .back, screen: .accessTypeSelection)
        }
    }
}

// MARK: - UITableViewDataSource

extension AccessTypePickerViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accessTypeNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let node = accessTypeNodes[indexPath.row]

        let cell = tableView.dequeueReusableCell(ofType: ProviderCell.self, for: indexPath)
        if let url = node.imageURL {
            cell.setImage(url: url)
        }

        let capabilities = node.providers.reduce(Provider.Capabilities()) { $0.union($1.capabilities) }

        cell.setDescription(text: capabilityFormatter.string(for: capabilities))
        cell.setTitle(text: node.accessType.description)

        let isBeta = node.providers.contains(where: { $0.releaseStatus == .beta })
        let isDemo = node.providers.contains(where: { $0.kind == .test })
        cell.setProviderTagLabelHidden(isBeta ? !isBeta : !isDemo, tag: isBeta ? .beta : .demo)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let accessTypeNode = accessTypeNodes[indexPath.row]

        switch accessTypeNode {
        case .credentialsKinds(let groups):
            providerPickerCoordinator?.showCredentialsKindPicker(for: groups)
        case .provider(let provider):
            providerPickerCoordinator?.didSelectProvider(provider)
        }
    }
}
