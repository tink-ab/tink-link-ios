import Foundation

/// An object that you use to get user consent.
public final class ConsentContext {
    private let clientID: String
    private let redirectURI: URL
    private let service: AuthenticationService

    /// Error that the `ConsentContext` can throw.
    public enum Error: Swift.Error {
        /// The scope or redirect URI was invalid.
        ///
        /// If you get this error make sure that your client has the scopes you're requesting and that you've added a valid redirect URI in Tink Console.
        ///
        /// - Note: The payload from the backend can be found in the associated value.
        case invalidScopeOrRedirectURI(String)

        init?(_ error: Swift.Error) {
            switch error {
            case ServiceError.invalidArgument(let message):
                self = .invalidScopeOrRedirectURI(message)
            default:
                return nil
            }
        }
    }

    // MARK: - Creating a Context

    /// Creates a context to authorize for an authorization code for a user with requested scopes.
    ///
    /// - Parameter tink: Tink instance, will use the shared instance if nothing is provided.
    public init(tink: Tink = .shared) {
        self.clientID = tink.configuration.clientID
        self.redirectURI = tink.configuration.redirectURI
        self.service = RESTAuthenticationService(tink: tink)
    }

    // MARK: - Getting Descriptions for Requested Scopes

    /// Lists scope descriptions for the provided scopes.
    ///
    /// If aggregating under Tink's license the user must be informed and fully understand what kind of data will be aggregated before aggregating any data.
    ///
    /// ## Showing Scope Descriptions
    /// Here's how you can list the scope descriptions for requesing access to accounts and transactions.
    ///
    ///     class ScopeDescriptionCell: UITableViewCell {
    ///         override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    ///             super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    ///             textLabel?.numberOfLines = 0
    ///             detailTextLabel?.numberOfLines = 0
    ///         }
    ///
    ///         required init?(coder: NSCoder) {
    ///             fatalError("init(coder:) has not been implemented")
    ///         }
    ///     }
    ///
    ///     class ScopeDescriptionsViewController: UITableViewController {
    ///         private let authorizationContext: AuthorizationContext
    ///
    ///         private var scopeDescriptions: [ScopeDescription] = []
    ///
    ///         init(user: User) {
    ///             self.authorizationContext = AuthorizationContext(user: user)
    ///             super.init(nibName: nil, bundle: nil)
    ///         }
    ///
    ///         required init?(coder aDecoder: NSCoder) {
    ///             fatalError("init(coder:) has not been implemented")
    ///         }
    ///
    ///         override func viewDidLoad() {
    ///             super.viewDidLoad()
    ///
    ///             tableView.register(ScopeDescriptionCell.self, forCellReuseIdentifier: "Cell")
    ///
    ///             let scopes [Scope] = [
    ///                 .accounts(.read),
    ///                 .transactions(.read)
    ///             ]
    ///
    ///             authorizationContext.fetchScopeDescriptions(scopes: scopes) { [weak self] result in
    ///                 DispatchQueue.main.async {
    ///                     do {
    ///                         self?.scopeDescriptions = try result.get()
    ///                         self?.tableView.reloadData()
    ///                     } catch {
    ///                         <#Error Handling#>
    ///                     }
    ///                 }
    ///             }
    ///         }
    ///
    ///         override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    ///             return scopeDescriptions.count
    ///         }
    ///
    ///         override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    ///             let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    ///             let scopeDescription = scopeDescriptions[indexPath.row]
    ///             cell.textLabel?.text = scopeDescription.title
    ///             cell.detailTextLabel?.text = scopeDescription.description
    ///             return cell
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///   - scope: A `Tink.Scope` list of OAuth scopes to be requested.
    ///            The Scope array should never be empty.
    ///   - completion: The block to execute when the scope descriptions are received or if an error occurred.
    /// - Returns: A Cancellable instance. Call cancel() on this instance if you no longer need the result of the request.
    @discardableResult
    public func fetchScopeDescriptions(scopes: [Scope], completion: @escaping (Result<[ScopeDescription], Swift.Error>) -> Void) -> RetryCancellable? {
        return service.clientDescription(clientID: clientID, scopes: scopes, redirectURI: redirectURI) { result in
            let mappedResult = result.map(\.scopes).mapError { Error($0) ?? $0 }
            if case .failure(Error.invalidScopeOrRedirectURI(let message)) = mappedResult {
                assertionFailure("Could not fetch scope descriptions: " + message)
            }
            completion(mappedResult)
        }
    }

    // MARK: - Getting Links to Terms and Conditions and Privacy Policy

    /// Get a link to the Terms & Conditions for TinkLink.
    ///
    /// ## Showing Terms and Conditions
    ///
    /// If aggregating under Tink's license the user must be presented with an option to view Tink’s Terms and Conditions and Privacy Policy before aggregating any data.
    ///
    /// Here's how you can get the url for the Terms and Conditions and present it with the `SFSafariViewController`.
    ///
    ///     func showTermsAndConditions() {
    ///         let url = consentContext.termsAndConditions(locale: <#appLocale#>)
    ///         let safariViewController = SFSafariViewController(url: url)
    ///         present(safariViewController, animated: true)
    ///     }
    ///
    /// - Parameter locale: The locale with the language to use.
    /// - Returns: A URL to the Terms & Conditions.
    /// - Note: Not all languages are supported.
    ///         The link will display the page in English if the requested language is not available.
    public func termsAndConditions(for locale: Locale = .current) -> URL {
        let languageCode = locale.languageCode ?? ""
        return URL(string: "https://link.tink.com/terms-and-conditions/\(languageCode)")!
    }

    /// Get a link to the Privacy Policy for TinkLink.
    ///
    /// ## Showing Privacy Policy
    ///
    /// If aggregating under Tink's license the user must be presented with an option to view Tink’s Terms and Conditions and Privacy Policy before aggregating any data.
    ///
    /// Here's how you can get the url for the Privacy Policy and present it with the `SFSafariViewController`.
    ///
    ///     func showPrivacyPolicy() {
    ///         let url = consentContext.privacyPolicy(locale: <#appLocale#>)
    ///         let safariViewController = SFSafariViewController(url: url)
    ///         present(safariViewController, animated: true)
    ///     }
    ///
    /// - Parameter locale: The locale with the language to use.
    /// - Returns: A URL to the Privacy Policy.
    /// - Note: Not all languages are supported.
    ///         The link will display the page in English if the requested language is not available.
    public func privacyPolicy(for locale: Locale = .current) -> URL {
        let languageCode = locale.languageCode ?? ""
        return URL(string: "https://link.tink.com/privacy-policy/\(languageCode)")!
    }
}
