import Down
import TinkLink
import UIKit

protocol AddCredentialViewControllerDelegate: AnyObject {
    func showScopeDescriptions()
    func showWebContent(with url: URL)
    func addCredential(provider: Provider, form: Form, allowAnotherDevice: Bool)
}

final class AddCredentialViewController: UIViewController {
    let provider: Provider
    var username: String? {
        credentialController.user?.username
    }

    weak var delegate: AddCredentialViewControllerDelegate?

    private let credentialController: CredentialController
    private let clientName: String
    private let isAggregator: Bool
    private var form: Form
    private var errors: [IndexPath: Form.Field.ValidationError] = [:]
    private var didFirstFieldBecomeFirstResponder = false
    private let keyboardObserver = KeyboardObserver()

    private lazy var tableView = UITableView(frame: .zero, style: .grouped)
    private lazy var helpLabel = UnselectableTextView()
    private lazy var headerView = AddCredentialHeaderView()
    private lazy var addCredentialFooterView = AddCredentialFooterView()
    private lazy var button: FloatingButton = {
        let button = FloatingButton()
        button.text = "Continue"
        return button
    }()

    private lazy var buttonBottomConstraint = addCredentialFooterView.topAnchor.constraint(equalTo: button.bottomAnchor)
    private lazy var buttonWidthConstraint = button.widthAnchor.constraint(greaterThanOrEqualToConstant: 200)

    init(provider: Provider, credentialController: CredentialController, clientName: String, isAggregator: Bool) {
        self.provider = provider
        self.form = Form(provider: provider)
        self.credentialController = credentialController
        self.clientName = clientName
        self.isAggregator = isAggregator

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension AddCredentialViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.background

        keyboardObserver.willShow = { [weak self] notification in
            self?.keyboardWillShow(notification)
        }
        keyboardObserver.willHide = { [weak self] notification in
            self?.keyboardWillHide(notification)
        }

        tableView.delegate = self
        tableView.dataSource = self

        headerView.configure(with: provider, username: username, clientName: clientName, isAggregator: isAggregator)
        headerView.delegate = self

        tableView.backgroundColor = .clear
        tableView.registerReusableCell(ofType: FormFieldTableViewCell.self)
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false

        addCredentialFooterView.delegate = self
        addCredentialFooterView.configure(with: provider, isAggregator: isAggregator)
        addCredentialFooterView.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(startAddCredentialFlow), for: .touchUpInside)
        addCredentialFooterView.bankIdAnotherDeviceButton.addTarget(self, action: #selector(addBankIDCredentialOnAnotherDevice), for: .touchUpInside)
        
        view.addSubview(tableView)
        view.addSubview(addCredentialFooterView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            addCredentialFooterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addCredentialFooterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            addCredentialFooterView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        navigationItem.title = "Authenticate"
        navigationItem.largeTitleDisplayMode = .never
        button.isEnabled = form.fields.isEmpty

        setupHelpFootnote()
        layoutHelpFootnote()
        setupButton()
    }

    func setupButton() {
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonWidthConstraint,
            button.heightAnchor.constraint(equalToConstant: 48),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonBottomConstraint,
        ])
        
        switch provider.credentialKind {
        case .mobileBankID:
            button.text = "Open BankID"
        default:
            button.text = "Continue"
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let headerHeight = headerView.systemLayoutSizeFitting(CGSize(width: view.frame.width, height: .greatestFiniteMagnitude), withHorizontalFittingPriority: .required, verticalFittingPriority: .init(249)).height
        var frame = headerView.frame
        frame.size.height = headerHeight
        tableView.tableHeaderView = headerView
        tableView.tableHeaderView?.frame = frame

        tableView.contentInset.bottom = addCredentialFooterView.frame.height
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()

        layoutHelpFootnote()
    }
}

// MARK: - Help Footnote

extension AddCredentialViewController {
    private func setupHelpFootnote() {

        let markdown = Down(markdownString: provider.helpText)
        helpLabel.attributedText = try? markdown.toAttributedString()
        helpLabel.backgroundColor = .clear
        helpLabel.isScrollEnabled = false
        helpLabel.isEditable = false
        helpLabel.textColor = Color.label

        let helpStackView = UIStackView(arrangedSubviews: [helpLabel])
        helpStackView.isLayoutMarginsRelativeArrangement = true

        tableView.tableFooterView = helpStackView
    }

    private func layoutHelpFootnote() {
        let footerLayoutMargins = UIEdgeInsets(top: 0, left: view.layoutMargins.left, bottom: 0, right: view.layoutMargins.right)

        let helpLabelSize = helpLabel.sizeThatFits(CGSize(width: view.bounds.inset(by: footerLayoutMargins).width, height: .infinity))

        tableView.tableFooterView?.layoutMargins = footerLayoutMargins

        tableView.tableFooterView?.frame = CGRect(
            origin: .zero,
            size: CGSize(
                width: view.bounds.width,
                height: helpLabelSize.height
            )
        )
    }
}

// MARK: - Keyboard Helper
extension AddCredentialViewController {
    private func keyboardWillShow(_ notification: KeyboardNotification) {
        updateButtonBottomConstraint(notification)
    }

    private func keyboardWillHide(_ notification: KeyboardNotification) {
        resetButtonBottomConstraint(notification)
    }

    private func updateButtonBottomConstraint(_ notification: KeyboardNotification) {
        let frameHeight = notification.frame.height
        buttonBottomConstraint.constant = max(0, frameHeight - addCredentialFooterView.bounds.height)
        buttonWidthConstraint.constant = view.frame.size.width
        button.rounded = false
        UIView.animate(withDuration: notification.duration) {
            self.view.layoutIfNeeded()
        }
    }

    private func resetButtonBottomConstraint(_ notification: KeyboardNotification) {
        buttonBottomConstraint.constant = 0
        buttonWidthConstraint.constant = button.minimumWidth
        button.rounded = true
        UIView.animate(withDuration: notification.duration) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDataSource

extension AddCredentialViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return form.fields.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = form.fields[indexPath.item]

        let cell = tableView.dequeueReusableCell(ofType: FormFieldTableViewCell.self, for: indexPath)
        cell.configure(with: field)
        cell.delegate = self
        cell.setError(with: errors[indexPath]?.localizedDescription)
        return cell
    }
}

// MARK: - Actions

extension AddCredentialViewController {
    @objc private func startAddCredentialFlow() {
        addCredential(allowAnotherDevice: false)
    }

    @objc private func addBankIDCredentialOnAnotherDevice() {
        addCredential(allowAnotherDevice: true)
    }

    private func addCredential(allowAnotherDevice: Bool) {
        view.endEditing(false)

        var indexPathsToUpdate = Set(errors.keys)
        errors = [:]

        do {
            try form.validateFields()
            delegate?.addCredential(provider: provider, form: form, allowAnotherDevice: allowAnotherDevice)
        } catch let error as Form.ValidationError {
            for (index, field) in form.fields.enumerated() {
                guard let error = error[fieldName: field.name] else {
                    continue
                }
                let indexPath = IndexPath(row: index, section: 0)
                errors[indexPath] = error
                indexPathsToUpdate.insert(indexPath)
            }
        } catch {
            assertionFailure("validateFields should only throw Form.ValidationError")
        }

        tableView.reloadRows(at: Array(indexPathsToUpdate), with: .automatic)
    }

    private func showMoreInfo() {
        delegate?.showScopeDescriptions()
    }

    private func showTermsAndConditions(_ url: URL) {
        delegate?.showWebContent(with: url)
    }

    private func showPrivacyPolicy(_ url: URL) {
        delegate?.showWebContent(with: url)
    }
}

// MARK: - TextFieldCellDelegate
extension AddCredentialViewController: FormFieldTableViewCellDelegate {
    func formFieldCellShouldReturn(_ cell: FormFieldTableViewCell) -> Bool {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return true
        }

        let lastIndexItem = form.fields.count - 1
        if lastIndexItem == indexPath.item {
            addCredential(allowAnotherDevice: false)
        }

        let nextIndexPath = IndexPath(row: indexPath.item + 1, section: indexPath.section)

        guard form.fields.count > nextIndexPath.item,
            form.fields[indexPath.item + 1].attributes.isEditable,
            let nextCell = tableView.cellForRow(at: nextIndexPath)
            else { return true }

        nextCell.becomeFirstResponder()

        return false
    }

    func formFieldCell(_ cell: FormFieldTableViewCell, willChangeToText text: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        form.fields[indexPath.item].text = text
        errors[indexPath] = nil
        tableView.beginUpdates()
        cell.setError(with: nil)
        tableView.endUpdates()
        button.isEnabled = form.areFieldsValid
    }

    func formFieldCellDidEndEditing(_ cell: FormFieldTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        let field = form.fields[indexPath.item]

        do {
            try field.validate()
            errors[indexPath] = nil
        } catch let error as Form.Field.ValidationError {
            errors[indexPath] = error
        } catch {
            print("Unknown error \(error).")
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - AddCredentialHeaderViewDelegate

extension AddCredentialViewController: AddCredentialHeaderViewDelegate {
    func addCredentialHeaderViewDidTapReadMore(_ addCredentialHeaderView: AddCredentialHeaderView) {
        showMoreInfo()
    }
}

// MARK: - AddCredentialFooterViewDelegate

extension AddCredentialViewController: AddCredentialFooterViewDelegate {
    func addCredentialFooterViewDidTapLink(_ addCredentialFooterView: AddCredentialFooterView, url: URL) {
        showPrivacyPolicy(url)
    }
}
