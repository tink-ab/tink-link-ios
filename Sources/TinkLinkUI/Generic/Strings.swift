import Foundation

private let tableName = "TinkLinkUI"
private let bundle: Bundle = .tinkLinkUI

enum Strings {
    enum Credentials {

        static let title = NSLocalizedString("Credentials.Title", tableName: tableName, bundle: bundle, value: "Authentication", comment: "Title for add credentials/authenticate screen.")

        static let openBankID = NSLocalizedString("Credentials.OpenBankID", tableName: tableName, bundle: bundle, value: "Open BankID", comment: "Text for BankID button shown in the add credentials/authenticate screen.")

        static let termsText = NSLocalizedString("Credentials.TermsText", tableName: tableName, bundle: bundle, value: "By using this service, you agree to Tink's %@ and %@ ", comment: "Text for BankID button shown in the add credentials/authenticate screen.")

        static let termsAndConditions = NSLocalizedString("Credentials.TermsAndConditions", tableName: tableName, bundle: bundle, value: "Terms and Conditions", comment: "Terms and conditions clickable text used in Credentials.TermsText.")

        static let privacyPolicy = NSLocalizedString("Credentials.PrivacyPolicy", tableName: tableName, bundle: bundle, value: "Privacy Policy", comment: "Privacy policy clickable text used in Credentials.TermsText.")

    enum ConsentInformation {

            /// Text explaining that the client will obtain financial information from the current user with a link for more information on which financial information specifically.
            static let text = NSLocalizedString("ConsentInformation.Text", tableName: tableName, bundle: bundle, value: "%@ will obtain some of your financial information. Read More", comment: "Text explaining that the client will obtain financial information from the current user with a link for more information on which financial information specifically.")

            static let readMore = NSLocalizedString("ConsentInformation.ReadMore", tableName: tableName, bundle: bundle, value: "Read More", comment: "Read more text (clickable) to lead to consent information.")

            /// Text explaining that when using the service, the user agrees to Tink's Terms and Conditions and Privacy Policy.
            static let serviceAgreement = NSLocalizedString("ConsentInformation.ServiceAgreement", tableName: tableName, bundle: bundle, value: "By using the service, you agree to Tink’s Terms and Conditions and Privacy Policy", comment: "Text explaining that when using the service, the user agrees to Tink's Terms and Conditions and Privacy Policy.")

            /// Title of the Privacy Policy link. This has to match the mention of the Privacy Policy in the `AddCredentials.Consent.ServiceAgreement` string.
            static let privacyPolicy = NSLocalizedString("ConsentInformation.PrivacyPolicy", tableName: tableName, bundle: bundle, value: "Privacy Policy", comment: "Title of the Privacy Policy link. This has to match the mention of the Privacy Policy in the `AddCredentials.Consent.ServiceAgreement` string.")

            /// Title of the Privacy Policy link. This has to match the mention of the Terms and Conditions in the `AddCredentials.Consent.ServiceAgreement` string.
            static let termsAndConditions = NSLocalizedString("ConsentInformation.TermsAndConditions", tableName: tableName, bundle: bundle, value: "Terms and Conditions", comment: "Title of the Privacy Policy link. This has to match the mention of the Terms and Conditions in the `AddCredentials.Consent.ServiceAgreement` string.")
        }

        enum Error {
            /// Title for error shown when a permanent failure occured while adding credentials.
            static let permanentFailure = NSLocalizedString("Credentials.Error.PermanentFailure", tableName: tableName, bundle: bundle, value: "Permanent error", comment: "Title for error shown when a permanent failure occured while adding credentials.")

            /// Title for error shown when a temporary failure occured while adding credentials.
            static let temporaryFailure = NSLocalizedString("Credentials.Error.TemporaryFailure", tableName: tableName, bundle: bundle, value: "Temporary error", comment: "Title for error shown when a temporary failure occured while adding credentials.")

            /// Title for error shown when authentication failed while adding credentials.
            static let authenticationFailed = NSLocalizedString("Credentials.Error.AuthenticationFailed", tableName: tableName, bundle: bundle, value: "Authentication failed", comment: "Title for error shown when authentication failed while adding credentials.")

            /// Message for error shown when credentials already exists.
            static let credentialsAlreadyExists = NSLocalizedString("Credentials.Error.CredentialsAlreadyExists", tableName: tableName, bundle: bundle, value: "You already have a connection to this bank or service.", comment: "Message for error shown when credentials already exists.")
        }

        enum Warning {
            /// Text for the warning shown when the developer is unverified.
            static let unverifiedClient = NSLocalizedString("Credentials.Warning.UnverifiedClient", tableName: tableName, bundle: bundle, value: "Unverified - This solution is only made for development purposes. Do not enter your bank credentials unless you trust the developer.", comment: "Text for the warning shown when the developer is unverified.")
        }

        enum Discard {
            /// Title for action sheet presented when user tries to dismiss modal while adding credentials.
            static let title = NSLocalizedString("Credentials.Discard.Title", tableName: tableName, bundle: bundle, value: "Are you sure you want to discard this new credential?", comment: "Title for action sheet presented when user tries to dismiss modal while adding credentials.")

            ///Title for action to discard adding credentials.
            static let primaryAction = NSLocalizedString("Credentials.Discard.PrimaryAction", tableName: tableName, bundle: bundle, value: "Discard Changes", comment: "Title for action to discard adding credentials.")

            /// Title for action to continue adding credentials.
            static let continueAction = NSLocalizedString("Credentials.Discard.ContinueAction", tableName: tableName, bundle: bundle, value: "Continue Editing", comment: "Title for action to continue adding credentials.")
        }

        enum Form {

            /// Title for screen where user fills in form to add credentials.
            static let authenticate = NSLocalizedString("Credentials.Form.Authenticate", tableName: tableName, bundle: bundle, value: "Authenticate", comment: "Title for screen where user fills in form to add credentials.")
        }
    }

    enum ConnectionSuccess {
        /// Title for screen shown when credentials were added successfully.
        static let title = NSLocalizedString("ConnectionSuccess.Title", tableName: tableName, bundle: bundle, value: "Connection successful", comment: "Title for screen shown when credentials were added successfully.")

        /// Subtitle for screen shown when credentials were added successfully.
        static let subtitle = NSLocalizedString("ConnectionSuccess.Subtitle", tableName: tableName, bundle: bundle, value: "Your account has successfully connected to %@.", comment: "Subtitle for screen shown when credentials were added successfully.")
    }

    enum ConsentInformation {
        static let title = NSLocalizedString("ConsentInformation.Title", tableName: tableName, bundle: bundle, value: "We'll collect the following data from you", comment: "Title shown in the concent information screen.")

        static let description = NSLocalizedString("ConsentInformation.Description", tableName: tableName, bundle: bundle, value: "By following through this service, we'll collect financial data from you. These are the data points we will collect from you", comment: "Description shown in the concent information screen.")
    }

    enum CredentialsStatus {
        /// Text shown when adding credentials and waiting for authorization.
        static let authorizing = NSLocalizedString("CredentialsStatus.Authorizing", tableName: tableName, bundle: bundle, value: "Authorizing…", comment: "Text shown for progress indicator dialog when in loading state.")

        /// Text shown when updating credentials.
        static let updating = NSLocalizedString("CredentialsStatus.Updating", tableName: tableName, bundle: bundle, value: "Connecting to %@, please wait…", comment: "Text shown for progress indicator dialog when status is CredentialStatus.Updating.")

        /// Fallback text shown when fail to get bank name while updating credentials.
        static let updatingFallback = NSLocalizedString("CredentialsStatus.UpdatingFallback", tableName: tableName, bundle: bundle, value: "Connecting, please wait…", comment: "Fallback text shown when fail to get bank name while updating credentials.")

        /// Text shown when submitting supplemental information.
        static let sending = NSLocalizedString("CredentialsStatus.Sending", tableName: tableName, bundle: bundle, value: "Sending…", comment: "Text shown for dialog when supplemental information is submitted and waiting for credential status update.")

        /// Text shown when canceling supplementing information.
        static let cancelling = NSLocalizedString("CredentialsStatus.Cancelling", tableName: tableName, bundle: bundle, value: "Cancelling…", comment: "Text shown for dialog when supplemental information is cancelled and waiting for credential status update.")

        /// Text shown when adding credentials and waiting for authentication on another device.
        static let waitingForAuthenticationOnAnotherDevice = NSLocalizedString("CredentialsStatus.WaitingForAuthenticationOnAnotherDevice", tableName: tableName, bundle: bundle, value: "Waiting for authentication on another device", comment: "Text shown when adding credentials and waiting for authentication on another device.")

        enum Connection {

            static let title = NSLocalizedString("CredentialsStatus.Connection.Title", tableName: tableName, bundle: bundle, value: "Connection successful", comment: "Title shown for connection successful screen.")

            static let description = NSLocalizedString("CredentialsStatus.Connection.Description", tableName: tableName, bundle: bundle, value: "Your accounts have been successfully added to %@", comment: "Description shown for connection successful screen.")

        }
    }

    enum Generic {
        /// Title for action to confirm alert.
        static let ok = NSLocalizedString("Generic.OK", tableName: tableName, bundle: bundle, value: "OK", comment: "Title for action to confirm alert.")

        /// Title for action to retry a failed request.
        static let retry = NSLocalizedString("Generic.Retry", tableName: tableName, bundle: bundle, value: "Try again", comment: "Title for action to retry a failed request.")

        /// Title for action to confirm an event.
        static let done = NSLocalizedString("Generic.Done", tableName: tableName, bundle: bundle, value: "Done", comment: "Title for action to confirm an event.")

        /// Title for cancelling an action or event.
        static let cancel = NSLocalizedString("Generic.Cancel", tableName: tableName, bundle: bundle, value: "Cancel", comment: "Text shown for Cancel button.")

        /// Title for button to send supplemental information when adding credentials.
        static let submit = NSLocalizedString("Generic.Submit", tableName: tableName, bundle: bundle, value: "Submit", comment: "Title for button to send supplemental information when adding credentials.")

        /// Title for action to dismiss error alert.
        static let dismiss = NSLocalizedString("Generic.Dismiss", tableName: tableName, bundle: bundle, value: "Dismiss", comment: "Title for action to dismiss error alert.")

        /// Title generic alert.
        static let error = NSLocalizedString("Generic.Error", tableName: tableName, bundle: bundle, value: "Error", comment: "Title generic alert.")

        /// Title for button to start authenticating credentials.
        static let `continue` = NSLocalizedString("Generic.Continue", tableName: tableName, bundle: bundle, value: "Continue", comment: "Title for generic button to continue an action.")

        enum ServiceAlert {
            /// Title for error alert if error doesn't contain a description.
            static let fallbackTitle = NSLocalizedString("Generic.ServiceAlert.FallbackTitle", tableName: tableName, bundle: bundle, value: "The service is unavailable at the moment.", comment: "Title for error alert if error doesn't contain a description.")

        }

        enum Formatter {
            /// Text used to form a list.
            static let and = NSLocalizedString("Generic.Formatter.And", tableName: tableName, bundle: bundle, value: "and", comment: "Text used to form a list.")
        }
        
    }

    enum ProviderList {

        /// Title for screen where user selects which access type to use when adding credentials.
        static let accessTypeTitle = NSLocalizedString("ProviderList.AccessTypeTitle", tableName: tableName, bundle: bundle, value: "Add %@", comment: "Title for screen where user selects which access type to use when adding credentials.")

        /// Title for screen where user selects which authentication type to use when adding credentials.
        static let credentialsTypeTitle = NSLocalizedString("ProviderList.CredentialsTypeTitle", tableName: tableName, bundle: bundle, value: "Sign in method", comment: "Title for screen where user selects which authentication type to use when adding credentials.")

        /// Title for list of all providers.
        static let title = NSLocalizedString("ProviderList.Title", tableName: tableName, bundle: bundle, value: "Choose bank", comment: "Title for list of all providers.")

        /// Placeholder in search field shown in provider list.
        static let searchHint = NSLocalizedString("ProviderList.SearchHint", tableName: tableName, bundle: bundle, value: "Search for a bank or card", comment: "Placeholder in search field shown in provider list.")

        enum Error {
            /// Title for when providers could not be loaded.
            static let title = NSLocalizedString("ProviderList.Error.Title", tableName: tableName, bundle: bundle, value: "We’re sorry, but we couldn't load any banks at the moment", comment: "Title for when providers could not be loaded.")

            /// Description for error when providers could not be loaded and it is likely it's a temporary error.
            static let temporary = NSLocalizedString("ProviderList.Error.Temporary", tableName: tableName, bundle: bundle, value: "This could be a temporary error, please try again and see if the problem persists.", comment: "Description for error when providers could not be loaded and it is likely it's a temporary error.")

            /// Description for error when providers could not be loaded.
            static let description = NSLocalizedString("ProviderList.Error.Description", tableName: tableName, bundle: bundle, value: "We are informed of this error and are working hard to resolve it. Bear with us, and try again a bit later.", comment: "Description for error when providers could not be loaded.")
        }
    }

    enum ProviderCapability {
        /// Description of the provider capability Transfers.
        static let transfers = NSLocalizedString("ProviderCapability.Transfers", tableName: tableName, bundle: bundle, value: "Transfers", comment: "Description of the provider capability Transfers.")

        /// Description of the provider capability Mortgage Aggregation.
        static let mortgageAggregation = NSLocalizedString("ProviderCapability.MortgageAggregation", tableName: tableName, bundle: bundle, value: "Mortgage Aggregation", comment: "Description of the provider capability Mortgage Aggregation.")

        /// Description of the provider capability Checking Accounts.
        static let checkingAccounts = NSLocalizedString("ProviderCapability.CheckingAccounts", tableName: tableName, bundle: bundle, value: "Checking Accounts", comment: "Description of the provider capability Checking Accounts.")

        /// Description of the provider capability Savings Accounts.
        static let savingsAccounts = NSLocalizedString("ProviderCapability.SavingsAccounts", tableName: tableName, bundle: bundle, value: "Savings Accounts", comment: "Description of the provider capability Savings Accounts.")

        /// Description of the provider capability Credit Cards.
        static let creditCards = NSLocalizedString("ProviderCapability.CreditCards", tableName: tableName, bundle: bundle, value: "Credit Cards", comment: "Description of the provider capability Credit Cards.")

        /// Description of the provider capability Investments.
        static let investments = NSLocalizedString("ProviderCapability.Investments", tableName: tableName, bundle: bundle, value: "Investments", comment: "Description of the provider capability Investments.")

        /// Description of the provider capability Loans.
        static let loans = NSLocalizedString("ProviderCapability.Loans", tableName: tableName, bundle: bundle, value: "Loans", comment: "Description of the provider capability Loans.")

        /// Description of the provider capability Payments.
        static let payments = NSLocalizedString("ProviderCapability.Payments", tableName: tableName, bundle: bundle, value: "Payments", comment: "Description of the provider capability Payments.")

        /// Description of the provider capability Mortgage Loan.
        static let mortgageLoan = NSLocalizedString("ProviderCapability.MortgageLoan", tableName: tableName, bundle: bundle, value: "Mortgage Loan", comment: "Description of the provider capability Mortgage Loan.")

        /// Description of the provider capability Identity Data.
        static let identityData = NSLocalizedString("ProviderCapability.IdentityData", tableName: tableName, bundle: bundle, value: "Identity Data", comment: "Description of the provider capability Identity Data.")

        /// Description of the provider capability E-Invoices.
        static let eInvoices = NSLocalizedString("ProviderCapability.EInvoices", tableName: tableName, bundle: bundle, value: "E-Invoices", comment: "Description of the provider capability E-Invoices.")
    }

    enum SelectAccessType {
        static let title = NSLocalizedString("SelectAccessType.Title", tableName: tableName, bundle: bundle, value: "Select account types", comment: "Title of the choose access type screen.")

        static let information = NSLocalizedString("SelectAccessType.Information", tableName: tableName, bundle: bundle, value: "Information about account types", comment: "Text for information button shown in the choose access type screen.")

        enum AccessType {
            /// Title for the group of providers that use Open Banking.
            static let openBankingTitle = NSLocalizedString("SelectAccessType.AccessType.OpenBankingTitle", tableName: tableName, bundle: bundle, value: "Checking accounts", comment: "Title for the group of providers that use Open Banking.")

            /// Text describing the group of providers that use Open Banking.
            static let openBankingDetail = NSLocalizedString("SelectAccessType.AccessType.OpenBankingDetail", tableName: tableName, bundle: bundle, value: "Including everyday accounts, such as your salary account.", comment: "Text describing the group of providers that use Open Banking.")

            /// Title for the group of providers that does not use Open Banking.
            static let otherTitle = NSLocalizedString("SelectAccessType.AccessType.OtherTitle", tableName: tableName, bundle: bundle, value: "Other account types", comment: "Title for the group of providers that does not use Open Banking.")

            /// Text describing the group of providers that does not use Open Banking.
            static let otherDetail = NSLocalizedString("SelectAccessType.AccessType.OtherDetail", tableName: tableName, bundle: bundle, value: "Including saving accounts, credit cards, loans, investments and your personal information.", comment: "Text describing the group of providers that does not use Open Banking.")
        }
    }

    enum SelectCredentialsType {
        static let title = NSLocalizedString("SelectCredentialsType.Title", tableName: tableName, bundle: bundle, value: "Sign in method", comment: "Title for choose credential type screen.")
    }

    enum SupplementalInformation {
        /// Title for form asking user to supplement information when adding credentials.
        static let title = NSLocalizedString("SupplementalInformation.Title", tableName: tableName, bundle: bundle, value: "Supplemental information", comment: "Title of the supplemental information dialog.")

        /// Title shown for QR code in the supplemental information dialog.
        static let qrCodeTitle = NSLocalizedString("SupplementalInformation.QRCodeTitle", tableName: tableName, bundle: bundle, value: "Open the BankID app", comment: "Title shown for QR code in the supplemental information dialog.")

        /// Title shown for QR code in the supplemental information dialog.
        static let qrCodeDescription = NSLocalizedString("SupplementalInformation.QRCodeDescription", tableName: tableName, bundle: bundle, value: "Open the BankID app and scan this QR code to authenticate.", comment: "Description shown for QR code in the supplemental information dialog.")

        /// Error shown for when QR could not be generated/displayed.
        static let qrCodeError = NSLocalizedString("SupplementalInformation.QRCodeError", tableName: tableName, bundle: bundle, value: "There is an error to load the QR code. Please try again later.", comment: "Error shown when QR code cannot be fetched/generated/displayed.")
    }
    enum ThirdPartyAppAuthentication {

        enum DownloadAlert {
            /// Title for action to download app for third-party app authentication.
            static let download = NSLocalizedString("ThirdPartyAppAuthentication.DownloadAlert.Download", tableName: tableName, bundle: bundle, value: "Download", comment: "Title for action to download app for third-party app authentication.")
        }
    }
}
