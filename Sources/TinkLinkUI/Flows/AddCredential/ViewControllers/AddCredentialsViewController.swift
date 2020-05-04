import Down
import TinkLink
import UIKit

protocol AddCredentialsViewControllerDelegate: AnyObject {
    func showScopeDescriptions()
    func showWebContent(with url: URL)
    func addCredential(provider: Provider, form: Form)
}

final class AddCredentialsViewController: UIViewController {
    let provider: Provider
    var username: String? {
        // FIXME: Fetch user to get username from.
        nil
    }

    weak var delegate: AddCredentialsViewControllerDelegate?

    var prefillStrategy: TinkLinkViewController.PrefillStrategy = .none

    private let credentialsController: CredentialsController
    private let clientName: String
    private let isAggregator: Bool
    private let isVerified: Bool
    private var form: Form
    private var errors: [IndexPath: Form.Field.ValidationError] = [:]
    private var didFirstFieldBecomeFirstResponder = false
    private let keyboardObserver = KeyboardObserver()
    private var currentScrollPos: CGFloat?

    private lazy var tableView = UITableView(frame: .zero, style: .grouped)
    private lazy var helpLabel = AddCredentialsHelpTextView()
    private lazy var headerView = AddCredentialsHeaderView()
    private lazy var addCredentialFooterView = AddCredentialsFooterView()
    private lazy var gradientView = GradientView()
    private lazy var button: FloatingButton = {
        let button = FloatingButton()
        button.text = Strings.AddCredentials.Form.continue
        return button
    }()

    private lazy var buttonBottomConstraint = addCredentialFooterView.topAnchor.constraint(equalTo: button.bottomAnchor)
    private lazy var buttonWidthConstraint = button.widthAnchor.constraint(greaterThanOrEqualToConstant: button.minimumWidth)

    init(provider: Provider, credentialsController: CredentialsController, clientName: String, isAggregator: Bool, isVerified: Bool) {
        self.provider = provider
        self.form = Form(provider: provider)
        self.credentialsController = credentialsController
        self.clientName = clientName
        self.isAggregator = isAggregator
        self.isVerified = isVerified

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Lifecycle

extension AddCredentialsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)
        view.backgroundColor = Color.background

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
        addCredentialFooterView.isHidden = isAggregator
        addCredentialFooterView.translatesAutoresizingMaskIntoConstraints = false
        addCredentialFooterView.backgroundColor = Color.background

        gradientView.colors = [Color.background.withAlphaComponent(0.0), Color.background]
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.isUserInteractionEnabled = false

        button.addTarget(self, action: #selector(startAddCredentialsFlow), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 180)

        view.addSubview(tableView)
        view.addSubview(gradientView)
        view.addSubview(addCredentialFooterView)
        view.addSubview(button)

        view.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)

        buttonBottomConstraint.constant = 24

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            addCredentialFooterView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            addCredentialFooterView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            addCredentialFooterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            gradientView.topAnchor.constraint(equalTo: button.topAnchor, constant: -40),
            gradientView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: addCredentialFooterView.topAnchor),

            buttonWidthConstraint,
            button.heightAnchor.constraint(equalToConstant: 48),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonBottomConstraint,
        ])

        navigationItem.title = Strings.AddCredentials.Form.title
        navigationItem.largeTitleDisplayMode = .never
        button.isEnabled = form.fields.filter({ $0.attributes.isEditable }).isEmpty

        setupHelpFootnote()
        layoutHelpFootnote()
        setupButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        keyboardObserver.willShow = { [weak self] notification in
            self?.keyboardWillShow(notification)
        }
        keyboardObserver.willHide = { [weak self] notification in
            self?.keyboardWillHide(notification)
        }
    }

    func setupButton() {
        switch provider.credentialsKind {
        case .mobileBankID:
            button.image = UIImage(icon: .bankID)
            button.text = Strings.AddCredentials.Form.openBankID
        default:
            button.text = Strings.AddCredentials.Form.continue
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let headerHeight = headerView.systemLayoutSizeFitting(CGSize(width: view.frame.width, height: .greatestFiniteMagnitude), withHorizontalFittingPriority: .required, verticalFittingPriority: .init(249)).height
        var frame = headerView.frame
        frame.size.height = headerHeight
        tableView.tableHeaderView = headerView
        tableView.tableHeaderView?.frame = frame
        tableView.contentInset.bottom = view.bounds.height - button.frame.minY - view.safeAreaInsets.bottom
        tableView.scrollIndicatorInsets.bottom = button.rounded ? 0 : tableView.contentInset.bottom
    }

    override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()

        layoutHelpFootnote()
    }
}

// MARK: - Help Footnote

extension AddCredentialsViewController {
    private func setupHelpFootnote() {
        guard let helpText = provider.helpText, !helpText.isEmpty else { return }
        helpLabel.configure(markdownString: helpText)
        tableView.tableFooterView = helpLabel
    }

    private func layoutHelpFootnote() { 
        guard let footerView = tableView.tableFooterView else {
            return
        }

        let footerSize = footerView.systemLayoutSizeFitting(CGSize(width: view.bounds.width, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)

        footerView.frame = CGRect(origin: .zero, size: CGSize(
                width: view.bounds.width,
                height: footerSize.height
            )
        )
    }
}

// MARK: - Keyboard Helper
extension AddCredentialsViewController {
    private func keyboardWillShow(_ notification: KeyboardNotification) {
        updateButtonBottomConstraint(notification)
    }

    private func keyboardWillHide(_ notification: KeyboardNotification) {
        resetButtonBottomConstraint(notification)
    }

    private func updateButtonBottomConstraint(_ notification: KeyboardNotification) {
        let frameHeight = notification.frame.height
        buttonBottomConstraint.constant = max(24, frameHeight - addCredentialFooterView.bounds.height)
        buttonWidthConstraint.constant = view.frame.size.width
        button.rounded = false
        UIView.animate(withDuration: notification.duration) {
            self.view.layoutIfNeeded()
        }
    }

    private func resetButtonBottomConstraint(_ notification: KeyboardNotification) {
        buttonBottomConstraint.constant = 24
        buttonWidthConstraint.constant = button.minimumWidth
        button.rounded = true
        UIView.animate(withDuration: notification.duration) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITableViewDataSource

extension AddCredentialsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return form.fields.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = form.fields[indexPath.item]

        let cell = tableView.dequeueReusableCell(ofType: FormFieldTableViewCell.self, for: indexPath)
        var viewModel = FormFieldTableViewCell.ViewModel(field: field)
        switch prefillStrategy {
        case .username(value: let name, isEditable: let isEditable):
            if indexPath.row == 0 {
                var testField = field
                testField.text = name
                guard testField.isValid else { break }
                viewModel.text = name
                viewModel.isEditable = isEditable ? field.attributes.isEditable : false
            }
        case .none:
            break
        }
        cell.configure(with: viewModel)
        cell.delegate = self
        cell.setError(with: errors[indexPath]?.localizedDescription)
        cell.textField.returnKeyType = indexPath.row < (form.fields.count - 1) ? .next : .continue
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return isVerified ? nil : AddCredentialsClientNotVerifiedView()
    }
}

// MARK: - Actions

extension AddCredentialsViewController {
    @objc private func startAddCredentialsFlow() {
        addCredential(allowAnotherDevice: false)
    }

    private func addCredential(allowAnotherDevice: Bool) {
        view.endEditing(false)

        var indexPathsToUpdate = Set(errors.keys)
        errors = [:]

        do {
            try form.validateFields()
            delegate?.addCredential(provider: provider, form: form)
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
extension AddCredentialsViewController: FormFieldTableViewCellDelegate {
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
            else {
                cell.resignFirstResponder()
                return true
        }

        nextCell.becomeFirstResponder()

        return false
    }

    func formFieldCell(_ cell: FormFieldTableViewCell, willChangeToText text: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        form.fields[indexPath.item].text = text
        errors[indexPath] = nil
        currentScrollPos = tableView.contentOffset.y
        tableView.beginUpdates()
        cell.setError(with: nil)
        tableView.endUpdates()
        currentScrollPos = nil
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
        currentScrollPos = tableView.contentOffset.y
        tableView.reloadRows(at: [indexPath], with: .automatic)
        currentScrollPos = nil
    }

    // To fix the issue for scroll view jumping while animating the cell, inspired by
    // https://stackoverflow.com/questions/33789807/uitableview-jumps-up-after-begin-endupdates-when-using-uitableviewautomaticdimen
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Force the tableView to stay at scroll position until animation completes
        if let currentScrollPos = currentScrollPos {
            tableView.setContentOffset(CGPoint(x: 0, y: currentScrollPos), animated: false)
        }
    }
}

// MARK: - AddCredentialsHeaderViewDelegate

extension AddCredentialsViewController: AddCredentialsHeaderViewDelegate {
    func addCredentialsHeaderViewDidTapReadMore(_ addCredentialsHeaderView: AddCredentialsHeaderView) {
        showMoreInfo()
    }
}

// MARK: - AddCredentialFooterViewDelegate

extension AddCredentialsViewController: AddCredentialsFooterViewDelegate {
    func addCredentialsFooterViewDidTapLink(_ addCredentialsFooterView: AddCredentialsFooterView, url: URL) {
        showPrivacyPolicy(url)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension AddCredentialsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !button.frame.contains(gestureRecognizer.location(in: view))
    }
}
