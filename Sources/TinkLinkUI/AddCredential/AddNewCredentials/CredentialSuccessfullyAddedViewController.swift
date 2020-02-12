import UIKit

class CredentialSuccessfullyAddedViewController: UIViewController {
    private let iconView = CheckmarkView(style: .large)
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let doneButton = UIButton(type: .system)
    
    //TODO: Use real strings
    private let titleText = "Connection successfull"
    private let subtitleText = "Your account has successfully connected to Company_Name. You'll be redirected back in a few seconds..."
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Color.background
        
        view.addSubview(containerView)
        containerView.addSubview(iconView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(detailLabel)
        view.addSubview(doneButton)
        
        iconView.isBorderHidden = true
        iconView.isChecked = true
        iconView.tintColor = .white
        iconView.strokeTintColor = Color.accent
        
        titleLabel.text = titleText
        titleLabel.textAlignment = .center
        titleLabel.font = Font.semibold(.mega)
        
        detailLabel.text = subtitleText
        detailLabel.textAlignment = .center
        detailLabel.numberOfLines = 0
        detailLabel.font = Font.regular(.deci)
        
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = Font.semibold(.hecto)
        doneButton.setTitleColor(Color.background, for: .normal)
        doneButton.backgroundColor = Color.accent
        doneButton.addTarget(self, action: #selector(doneActionPressed), for: .touchUpInside)
        doneButton.contentEdgeInsets = UIEdgeInsets(top: 13, left: 68, bottom: 16, right: 68)
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            iconView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconView.topAnchor.constraint(equalTo: containerView.layoutMarginsGuide.topAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: iconView.centerYAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.leadingAnchor, constant: -24),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.trailingAnchor, constant: 24),
            
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            detailLabel.leadingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.leadingAnchor, constant: -24),
            detailLabel.trailingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.trailingAnchor, constant: 24),
            detailLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -40)
        ])
    }
    
    @objc func doneActionPressed() {
        //TODO: End AIS-process and proceed to app?
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        doneButton.layer.cornerRadius = doneButton.bounds.height / 2
    }
}
