import UIKit
import TinkLink

class CredentialSuccessfullyAddedViewController: UIViewController {
    let companyName: String
    let doneActionHandler: () -> Void

    private let iconView = CheckmarkView(style: .large)
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let doneButton = FloatingButton()
    
    init(companyName: String, doneActionHandler: @escaping () -> Void) {
        self.companyName = companyName
        self.doneActionHandler = doneActionHandler
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //TODO: Use real strings
    private let titleText = NSLocalizedString("AddCredentials.Success.Title", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "Connection successful", comment: "Title for screen shown when credentials were added successfully.")
    private let subtitleText = NSLocalizedString("AddCredentials.Success.Subtitle", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "Your account has successfully connected to %@.", comment: "Subtitle for screen shown when credentials were added successfully.")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Color.background
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubview(containerView)
        containerView.addSubview(iconView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(detailLabel)
        view.addSubview(doneButton)

        iconView.isChecked = true
        iconView.tintColor = Color.accent
        iconView.strokeTintColor = Color.background
        
        titleLabel.text = titleText
        titleLabel.textAlignment = .center
        titleLabel.font = Font.semibold(.hecto)
        titleLabel.textColor = Color.label

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        detailLabel.attributedText = NSAttributedString(string: String(format: subtitleText, companyName), attributes: [.paragraphStyle: paragraphStyle])
        detailLabel.textAlignment = .center
        detailLabel.numberOfLines = 0
        detailLabel.font = Font.regular(.deci)
        detailLabel.textColor = Color.label
        
        doneButton.text = NSLocalizedString("AddCredentials.Success.Confirm", tableName: "TinkLinkUI", bundle: .tinkLinkUI, value: "Done", comment: "Title for button to dismiss the screen shown when credentials were added successfully.")
        doneButton.addTarget(self, action: #selector(doneActionPressed), for: .touchUpInside)
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -48),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            iconView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconView.topAnchor.constraint(equalTo: containerView.layoutMarginsGuide.topAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.trailingAnchor, constant: -24),
            
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            detailLabel.leadingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.leadingAnchor, constant: 24),
            detailLabel.trailingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.trailingAnchor, constant: -24),
            detailLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -32)
        ])
    }
    
    @objc func doneActionPressed() {
        doneActionHandler()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        doneButton.layer.cornerRadius = doneButton.bounds.height / 2
    }
}
