import Foundation

private let tableName = "TinkLinkUI"
private let bundle: Bundle = .tinkLinkUI

enum Strings {
    enum ConnectionSuccess {
        enum Create {
            /// Subtitle for screen shown when credentials were added successfully.
            static let subtitle = NSLocalizedString("ConnectionSuccess.Create.Subtitle", tableName: tableName, bundle: bundle, value: "You have successfully connected to %@.", comment: "Subtitle for screen shown when credentials were added successfully.")

            /// Title for screen shown when credentials were added successfully.
            static let title = NSLocalizedString("ConnectionSuccess.Create.Title", tableName: tableName, bundle: bundle, value: "Connection successful", comment: "Title for screen shown when credentials were added successfully.")
        }

        enum Update {
            /// Subtitle for screen shown when credentials were added successfully.
            static let subtitle = NSLocalizedString("ConnectionSuccess.Update.Subtitle", tableName: tableName, bundle: bundle, value: "Your connection to %@ has successfully updated.", comment: "Subtitle for screen shown when credentials were added successfully.")

            /// Title for screen shown when credentials were added successfully.
            static let title = NSLocalizedString("ConnectionSuccess.Update.Title", tableName: tableName, bundle: bundle, value: "Update successful", comment: "Title for screen shown when credentials were added successfully.")
        }
    }

    enum ConsentInformation {
        static let description = NSLocalizedString("ConsentInformation.Description", tableName: tableName, bundle: bundle, value: "By following through this service, we'll collect financial data from you. These are the data points we will collect from you:", comment: "Description shown in the concent information screen.")

        static let title = NSLocalizedString("ConsentInformation.Title", tableName: tableName, bundle: bundle, value: "We'll collect the following data from you", comment: "Title shown in the concent information screen.")
    }

    enum Credentials {
        static let openBankID = NSLocalizedString("Credentials.OpenBankID", tableName: tableName, bundle: bundle, value: "Open BankID", comment: "Text for BankID button shown in the add credentials/authenticate screen.")

        static let privacyPolicy = NSLocalizedString("Credentials.PrivacyPolicy", tableName: tableName, bundle: bundle, value: "Privacy Policy", comment: "Privacy policy clickable text used in Credentials.TermsAndConsentText.")

        static let viewDetails = NSLocalizedString("Credentials.ViewDetails", tableName: tableName, bundle: bundle, value: "View details", comment: "View details text (clickable) to lead to consent information that used in Credentials.TermsAndConsentText.")

        static let termsAndConditions = NSLocalizedString("Credentials.TermsAndConditions", tableName: tableName, bundle: bundle, value: "Terms and Conditions", comment: "Terms and conditions clickable text used in Credentials.TermsAndConsentText.")

        static let instructions = NSLocalizedString("Credentials.Instructions", tableName: tableName, bundle: bundle, value: "1. You will be securely transferred to %@.\r\n2. You will be required to authenticate.\r\n3. Once authenticated, you will be redirected back.", comment: "Instruction texts for credentials that need to redirect")

        /// Text explaining that when using the service, the user agrees to Tink's Terms and Conditions, Privacy Policy. And the text explaining that the client will obtain financial information from the current user with a link for more information on which financial information specifically.
        static let termsAndConsentText = NSLocalizedString("Credentials.TermsAndConsentText", tableName: tableName, bundle: bundle, value: "By using the service, you agree to Tink’s %@ and %@. %@ will obtain parts of your financial information. %@", comment: "Text explaining that when using the service, the user agrees to Tink's Terms and Conditions, Privacy Policy. And the text explaining that the client will obtain financial information from the current user with a link for more information on which financial information specifically.")

        static let title = NSLocalizedString("Credentials.Title", tableName: tableName, bundle: bundle, value: "Authentication", comment: "Title for add credentials/authenticate screen.")

        static let description = NSLocalizedString("Credentials.Description", tableName: tableName, bundle: bundle, value: "Log in to %@ to continue", comment: "Description text for add credentials screen.")

        /// Text for the warning shown when the developer is unverified.
        static let unverifiedClient = NSLocalizedString("Credentials.UnverifiedClient", tableName: tableName, bundle: bundle, value: "Unverified - This solution is only made for development purposes. Do not enter your bank credentials unless you trust the developer.", comment: "Text for the warning shown when the developer is unverified.")

        enum Discard {
            /// Title for action to continue adding credentials.
            static let continueAction = NSLocalizedString("Credentials.Discard.ContinueAction", tableName: tableName, bundle: bundle, value: "No, continue", comment: "Title for action to continue adding credentials.")

            /// Title for action to discard adding credentials.
            static let primaryAction = NSLocalizedString("Credentials.Discard.PrimaryAction", tableName: tableName, bundle: bundle, value: "Yes, cancel", comment: "Title for action to discard adding credentials.")

            /// Title for action sheet presented when user tries to dismiss modal while adding credentials.
            static let title = NSLocalizedString("Credentials.Discard.Title", tableName: tableName, bundle: bundle, value: "Are you sure you want to cancel?", comment: "Title for action sheet presented when user tries to dismiss modal while adding credentials.")

            /// Message for action sheet presented when user tries to dismiss modal while adding credentials.
            static let message = NSLocalizedString("Credentials.Discard.Message", tableName: tableName, bundle: bundle, value: "Connecting to your bank is fully secure and only takes a minute.", comment: "Message for action sheet presented when user tries to dismiss modal while adding credentials.")
        }

        enum Error {
            /// Title for error shown when authentication failed while adding credentials.
            static let authenticationFailed = NSLocalizedString("Credentials.Error.AuthenticationFailed", tableName: tableName, bundle: bundle, value: "Authentication failed", comment: "Title for error shown when authentication failed while adding credentials.")

            /// Message for error shown when credentials already exists.
            static let credentialsAlreadyExists = NSLocalizedString("Credentials.Error.CredentialsAlreadyExists", tableName: tableName, bundle: bundle, value: "You already have a connection to this bank or service.", comment: "Message for error shown when credentials already exists.")

            /// Title for error shown when a permanent failure occured while adding credentials.
            static let permanentFailure = NSLocalizedString("Credentials.Error.PermanentFailure", tableName: tableName, bundle: bundle, value: "Permanent error", comment: "Title for error shown when a permanent failure occured while adding credentials.")

            /// Title for error shown when a temporary failure occured while adding credentials.
            static let temporaryFailure = NSLocalizedString("Credentials.Error.TemporaryFailure", tableName: tableName, bundle: bundle, value: "Temporary error", comment: "Title for error shown when a temporary failure occured while adding credentials.")

            /// Default title for error shown when download authentication app is required while adding credentials.
            static let downloadRequired = NSLocalizedString("Credentials.Error.DownloadRequired", tableName: tableName, bundle: bundle, value: "Authentication app download required", comment: "Default title for error shown when download authentication app is required while adding credentials.")
        }
    }

    enum CredentialsStatus {
        /// Text shown when adding credentials and waiting for authorization.
        static let authorizing = NSLocalizedString("CredentialsStatus.Authorizing", tableName: tableName, bundle: bundle, value: "Authorizing…", comment: "Text shown for progress indicator dialog when in loading state.")

        /// Text shown when canceling supplementing information.
        static let cancelling = NSLocalizedString("CredentialsStatus.Cancelling", tableName: tableName, bundle: bundle, value: "Cancelling…", comment: "Text shown for dialog when supplemental information is cancelled and waiting for credential status update.")

        /// Text shown when submitting supplemental information.
        static let sending = NSLocalizedString("CredentialsStatus.Sending", tableName: tableName, bundle: bundle, value: "Sending…", comment: "Text shown for dialog when supplemental information is submitted and waiting for credential status update.")

        /// Text shown when updating credentials.
        static let updating = NSLocalizedString("CredentialsStatus.Updating", tableName: tableName, bundle: bundle, value: "Connecting to %@, please wait…", comment: "Text shown for progress indicator dialog when status is CredentialStatus.Updating.")

        /// Fallback text shown when fail to get bank name while updating credentials.
        static let updatingFallback = NSLocalizedString("CredentialsStatus.UpdatingFallback", tableName: tableName, bundle: bundle, value: "Connecting, please wait…", comment: "Fallback text shown when fail to get bank name while updating credentials.")

        /// Text shown when adding credentials and waiting for authentication on another device.
        static let waitingForAuthenticationOnAnotherDevice = NSLocalizedString("CredentialsStatus.WaitingForAuthenticationOnAnotherDevice", tableName: tableName, bundle: bundle, value: "Waiting for authentication on another device", comment: "Text shown when adding credentials and waiting for authentication on another device.")
    }

    enum Generic {
        static let and = NSLocalizedString("Generic.And", tableName: tableName, bundle: bundle, value: "and", comment: "Text used to form a list.")

        /// Title for cancelling an action or event.
        static let cancel = NSLocalizedString("Generic.Cancel", tableName: tableName, bundle: bundle, value: "Cancel", comment: "Text shown for Cancel button.")

        /// Title for generic close button.
        static let close = NSLocalizedString("Generic.Close", tableName: tableName, bundle: bundle, value: "Close", comment: "Title for generic close button.")

        /// Title for button to start authenticating credentials.
        static let `continue` = NSLocalizedString("Generic.Continue", tableName: tableName, bundle: bundle, value: "Continue", comment: "Title for generic button to continue an action.")

        /// Title for action to dismiss error alert.
        static let dismiss = NSLocalizedString("Generic.Dismiss", tableName: tableName, bundle: bundle, value: "Dismiss", comment: "Title for action to dismiss error alert.")

        /// Title for generic text to login.
        static let login = NSLocalizedString("Generic.Login", tableName: tableName, bundle: bundle, value: "Log in", comment: "Title for generic text to login.")

        /// Title for action to confirm an event.
        static let done = NSLocalizedString("Generic.Done", tableName: tableName, bundle: bundle, value: "Done", comment: "Title for action to confirm an event.")

        /// Title generic alert.
        static let error = NSLocalizedString("Generic.Error", tableName: tableName, bundle: bundle, value: "Something went wrong. Please try again later.", comment: "Title generic alert.")

        /// Title for action to confirm alert.
        static let ok = NSLocalizedString("Generic.OK", tableName: tableName, bundle: bundle, value: "OK", comment: "Title for action to confirm alert.")

        /// Title for action to retry a failed request.
        static let retry = NSLocalizedString("Generic.Retry", tableName: tableName, bundle: bundle, value: "Try again", comment: "Title for action to retry a failed request.")

        /// Title for cancelled request.
        static let cancelled = NSLocalizedString("Generic.Cancelled", tableName: tableName, bundle: bundle, value: "Cancelled", comment: "Title for cancelled request.")

        enum ServiceAlert {
            /// Title for error alert if error doesn't contain a description.
            static let fallbackTitle = NSLocalizedString("Generic.ServiceAlert.FallbackTitle", tableName: tableName, bundle: bundle, value: "The service is unavailable at the moment.", comment: "Title for error alert if error doesn't contain a description.")
        }
    }

    enum ProviderCapability {
        /// Description of the provider capability Checking Accounts.
        static let checkingAccounts = NSLocalizedString("ProviderCapability.CheckingAccounts", tableName: tableName, bundle: bundle, value: "Checking Accounts", comment: "Description of the provider capability Checking Accounts.")

        /// Description of the provider capability Credit Cards.
        static let creditCards = NSLocalizedString("ProviderCapability.CreditCards", tableName: tableName, bundle: bundle, value: "Credit Cards", comment: "Description of the provider capability Credit Cards.")

        /// Description of the provider capability E-Invoices.
        static let eInvoices = NSLocalizedString("ProviderCapability.EInvoices", tableName: tableName, bundle: bundle, value: "E-Invoices", comment: "Description of the provider capability E-Invoices.")

        /// Description of the provider capability Identity Data.
        static let identityData = NSLocalizedString("ProviderCapability.IdentityData", tableName: tableName, bundle: bundle, value: "Identity Data", comment: "Description of the provider capability Identity Data.")

        /// Description of the provider capability Investments.
        static let investments = NSLocalizedString("ProviderCapability.Investments", tableName: tableName, bundle: bundle, value: "Investments", comment: "Description of the provider capability Investments.")

        /// Description of the provider capability Loans.
        static let loans = NSLocalizedString("ProviderCapability.Loans", tableName: tableName, bundle: bundle, value: "Loans", comment: "Description of the provider capability Loans.")

        /// Description of the provider capability Mortgage Aggregation.
        static let mortgageAggregation = NSLocalizedString("ProviderCapability.MortgageAggregation", tableName: tableName, bundle: bundle, value: "Mortgage Aggregation", comment: "Description of the provider capability Mortgage Aggregation.")

        /// Description of the provider capability Mortgage Loan.
        static let mortgageLoan = NSLocalizedString("ProviderCapability.MortgageLoan", tableName: tableName, bundle: bundle, value: "Mortgage Loan", comment: "Description of the provider capability Mortgage Loan.")

        /// Description of the provider capability Payments.
        static let payments = NSLocalizedString("ProviderCapability.Payments", tableName: tableName, bundle: bundle, value: "Payments", comment: "Description of the provider capability Payments.")

        /// Description of the provider capability Savings Accounts.
        static let savingsAccounts = NSLocalizedString("ProviderCapability.SavingsAccounts", tableName: tableName, bundle: bundle, value: "Savings Accounts", comment: "Description of the provider capability Savings Accounts.")

        /// Description of the provider capability Transfers.
        static let transfers = NSLocalizedString("ProviderCapability.Transfers", tableName: tableName, bundle: bundle, value: "Transfers", comment: "Description of the provider capability Transfers.")
    }

    enum ProviderList {
        /// Placeholder in search field shown in provider list.
        static let searchHint = NSLocalizedString("ProviderList.SearchHint", tableName: tableName, bundle: bundle, value: "Search for a bank or card", comment: "Placeholder in search field shown in provider list.")

        /// Title for list of all providers.
        static let title = NSLocalizedString("ProviderList.Title", tableName: tableName, bundle: bundle, value: "Choose your bank", comment: "Title for list of all providers.")

        /// Description for when provider list is empty.
        static let emptyList = NSLocalizedString("ProviderList.EmptyList", tableName: tableName, bundle: bundle, value: "No banks found", comment: "Description for when provider list is empty.")

        enum Error {
            /// Description for error when providers could not be loaded.
            static let description = NSLocalizedString("ProviderList.Error.Description", tableName: tableName, bundle: bundle, value: "There was an error while connecting to the banks, please try again or come back later.", comment: "Description for error when providers could not be loaded.")

            /// Description for error when providers could not be loaded and it is likely it's a temporary error.
            static let temporary = NSLocalizedString("ProviderList.Error.Temporary", tableName: tableName, bundle: bundle, value: "This could be a temporary error, please try again and see if the problem persists.", comment: "Description for error when providers could not be loaded and it is likely it's a temporary error.")

            /// Title for when providers could not be loaded.
            static let title = NSLocalizedString("ProviderList.Error.Title", tableName: tableName, bundle: bundle, value: "Couldn’t load any banks", comment: "Title for when providers could not be loaded.")
        }
    }

    enum SelectAccessType {
        /// Information text shown in the choose access type screen.
        static let information = NSLocalizedString("SelectAccessType.Information", tableName: tableName, bundle: bundle, value: "Due to EU regulations different account types need to be connected separately.", comment: "Information text shown in the choose access type screen.")

        /// Title for screen where user selects which access type to use when adding credentials.
        static let title = NSLocalizedString("SelectAccessType.Title", tableName: tableName, bundle: bundle, value: "Connection type", comment: "Title of the choose access type screen.")

        /// Title for the other account type (not an open banking account type) on the choose access type screen.
        static let otherType = NSLocalizedString("SelectAccessType.OtherType", tableName: tableName, bundle: bundle, value: "Other", comment: "Title for the other account type (not an open banking account type) on the choose access type screen.")
    }

    enum SelectAuthenticationUserType {
        /// Title for the business authentication user type
        static let business = NSLocalizedString("SelectAuthenticationUserType.Business", tableName: tableName, bundle: bundle, value: "Business", comment: "Title for the business authentication user type")

        /// Title for the personal authentication user type
        static let personal = NSLocalizedString("SelectAuthenticationUserType.Personal", tableName: tableName, bundle: bundle, value: "Personal", comment: "Title for the personal authentication user type")

        /// Title for the corporate authentication user type
        static let corporate = NSLocalizedString("SelectAuthenticationUserType.Corporate", tableName: tableName, bundle: bundle, value: "Corporate", comment: "Title for the corporate authentication user type")

        /// Title when picking authentication user type.
        static let title = NSLocalizedString("SelectAuthenticationUserType.Title", tableName: tableName, bundle: bundle, value: "Login type", comment: "Title when picking authentication user type.")
    }

    enum SelectCredentialsType {
        /// Title for screen where user selects which authentication type to use when adding credentials.
        static let title = NSLocalizedString("SelectCredentialsType.Title", tableName: tableName, bundle: bundle, value: "Sign in method", comment: "Title for choose credential type screen.")
    }

    enum SupplementalInformation {
        /// Title shown for QR code in the supplemental information dialog.
        static let qrCodeDescription = NSLocalizedString("SupplementalInformation.QRCodeDescription", tableName: tableName, bundle: bundle, value: "Open the BankID app and scan this QR code to authenticate.", comment: "Description shown for QR code in the supplemental information dialog.")

        /// Error shown for when QR could not be generated/displayed.
        static let qrCodeError = NSLocalizedString("SupplementalInformation.QRCodeError", tableName: tableName, bundle: bundle, value: "There is an error to load the QR code. Please try again later.", comment: "Error shown when QR code cannot be fetched/generated/displayed.")

        /// Title shown for QR code in the supplemental information dialog.
        static let qrCodeTitle = NSLocalizedString("SupplementalInformation.QRCodeTitle", tableName: tableName, bundle: bundle, value: "Open the BankID app", comment: "Title shown for QR code in the supplemental information dialog.")

        /// Title for form asking user to supplement information when adding credentials.
        static let title = NSLocalizedString("SupplementalInformation.Title", tableName: tableName, bundle: bundle, value: "Supplemental information", comment: "Title of the supplemental information dialog.")

        /// Title for button to submit supplemental information.
        static let submit = NSLocalizedString("SupplementalInformation.Submit", tableName: tableName, bundle: bundle, value: "Submit", comment: "Title for button to submit supplemental information.")
    }

    enum ThirdPartyAppAuthentication {
        enum DownloadAlert {
            /// Title for action to download app for third-party app authentication.
            static let download = NSLocalizedString("ThirdPartyAppAuthentication.DownloadAlert.Download", tableName: tableName, bundle: bundle, value: "Download", comment: "Title for action to download app for third-party app authentication.")
        }
    }

    enum Field {
        enum ValidationError {
            /// Text for field validation error shown when field exceeds character limit.
            static let maxLengthLimit = NSLocalizedString("Field.Validation.MaxLengthLimit", tableName: tableName, bundle: bundle, value: "This field cannot be longer than %d characters", comment: "Text for field validation error shown when text entered exceeds character limit.")

            /// Text for field validation error shown when text entered is shorter than required.
            static let minLengthLimit = NSLocalizedString("Field.Validation.MinLengthLimit", tableName: tableName, bundle: bundle, value: "This field must be at least %d characters.", comment: "Text for field validation error shown when text entered is shorter than required.")

            /// Text for field validation error shown when no text is entered for a required field.
            static let requiredFieldEmptyValue = NSLocalizedString("Field.Validation.RequiredFieldEmptyValue", tableName: tableName, bundle: bundle, value: "This field cannot be empty", comment: "Text for field validation error shown when no text is entered for a required field.")
        }
    }
}
