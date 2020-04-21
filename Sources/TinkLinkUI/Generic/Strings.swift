import Foundation

private let tableName = "TinkLinkUI"
private let bundle: Bundle = .tinkLinkUI

enum Strings {
    enum AddCredentials {

        enum Discard {
            /// Title for action sheet presented when user tries to dismiss modal while adding credentials.
            static let title = NSLocalizedString("AddCredentials.Discard.Title", tableName: tableName, bundle: bundle, value: "Are you sure you want to discard this new credential?", comment: "Title for action sheet presented when user tries to dismiss modal while adding credentials.")

            ///Title for action to discard adding credentials.
            static let primaryAction = NSLocalizedString("AddCredentials.Discard.PrimaryAction", tableName: tableName, bundle: bundle, value: "Discard Changes", comment: "Title for action to discard adding credentials.")

            /// Title for action to continue adding credentials.
            static let continueAction = NSLocalizedString("AddCredentials.Discard.ContinueAction", tableName: tableName, bundle: bundle, value: "Continue Editing", comment: "Title for action to continue adding credentials.")
        }

        enum Error {
            /// Title for error shown when a permanent failure occured while adding credentials.
            static let permanentFailure = NSLocalizedString("AddCredentials.Error.PermanentFailure", tableName: tableName, bundle: bundle, value: "Permanent error", comment: "Title for error shown when a permanent failure occured while adding credentials.")

            /// Title for error shown when a temporary failure occured while adding credentials.
            static let temporaryFailure = NSLocalizedString("AddCredentials.Error.TemporaryFailure", tableName: tableName, bundle: bundle, value: "Temporary error", comment: "Title for error shown when a temporary failure occured while adding credentials.")

            /// Title for error shown when authentication failed while adding credentials.
            static let authenticationFailed = NSLocalizedString("AddCredentials.Error.AuthenticationFailed", tableName: tableName, bundle: bundle, value: "Authentication failed", comment: "Title for error shown when authentication failed while adding credentials.")

            /// Title for error shown when credentials already exists.
            static let credentialsAlreadyExists =
            NSLocalizedString("AddCredentials.Error.CredentialsAlreadyExists", tableName: tableName, bundle: bundle, value: "Error", comment: "Title for error shown when credentials already exists.")

            /// Message for error shown when credentials already exists.
            static let credentialsAlreadyExistsDetail = NSLocalizedString("AddCredentials.Error.CredentialsAlreadyExists.FailureReason", tableName: tableName, bundle: bundle, value: "You already have a connection to this bank or service.", comment: "Message for error shown when credentials already exists.")
        }

        enum Form {
            /// Title for button to start authenticating credentials.
            static let `continue` = NSLocalizedString("AddCredentials.Form.Continue", tableName: tableName, bundle: bundle, value: "Continue", comment: "Title for button to start authenticating credentials.")

            /// Title for screen where user fills in form to add credentials.
            static let title = NSLocalizedString("AddCredentials.Form.Title", tableName: tableName, bundle: bundle, value: "Authenticate", comment: "Title for screen where user fills in form to add credentials.")

            /// Title for button to open BankID app.
            static let openBankID = NSLocalizedString("AddCredentials.Form.OpenBankID", tableName: tableName, bundle: bundle, value: "Open BankID", comment: "Title for button to open BankID app.")
        }

        enum ScopeDescriptions {
            /// Title for text introducing the descriptions for which data points will be collected when using the service.
            static let title = NSLocalizedString("AddCredentials.ScopeDescriptions.Title", tableName: tableName, bundle: bundle, value: "We’ll collect the following data from you", comment: "Title for text introducing the descriptions for which data points will be collected when using the service.")

            /// Text introducing the descriptions for which data points will be collected when using the service.
            static let body =  NSLocalizedString("AddCredentials.ScopeDescriptions.Body", tableName: tableName, bundle: bundle, value: "By following through this service, we’ll collect financial data from you. These are the data points we will collect from you:", comment: "Text introducing the descriptions for which data points will be collected when using the service.")
        }

        enum Success {
            /// Title for screen shown when credentials were added successfully.
            static let title = NSLocalizedString("AddCredentials.Success.Title", tableName: tableName, bundle: bundle, value: "Connection successful", comment: "Title for screen shown when credentials were added successfully.")

            /// Subtitle for screen shown when credentials were added successfully.
            static let subtitle = NSLocalizedString("AddCredentials.Success.Subtitle", tableName: tableName, bundle: bundle, value: "Your account has successfully connected to %@.", comment: "Subtitle for screen shown when credentials were added successfully.")

            /// Title for button to dismiss the screen shown when credentials were added successfully.
            static let confirm = NSLocalizedString("AddCredentials.Success.Confirm", tableName: tableName, bundle: bundle, value: "Done", comment: "Title for button to dismiss the screen shown when credentials were added successfully.")


        }
        enum Status {
            /// Title for button to cancel an ongoing task for adding credentials.
            static let cancel = NSLocalizedString("AddCredentials.Status.Cancel", tableName: tableName, bundle: bundle, value: "Cancel", comment: "Title for button to cancel an ongoing task for adding credentials.")

            /// Text shown when adding credentials and waiting for authorization.
            static let authorizing = NSLocalizedString("AddCredentials.Status.Authorizing", tableName: tableName, bundle: bundle, value: "Authorizing…", comment: "Text shown when adding credentials and waiting for authorization.")

            /// Text shown when updating credentials.
            static let updating = NSLocalizedString("AddCredentials.Status.Updating", tableName: tableName, bundle: bundle, value: "Connecting to %@, please wait…", comment: "Text shown when updating credentials.")

            /// Fallback text shown when fail to get bank name while updating credentials.
            static let updatingFallback = NSLocalizedString("AddCredentials.Status.Updating.Fallback", tableName: tableName, bundle: bundle, value: "Connecting, please wait…", comment: "Fallback text shown when fail to get bank name while updating credentials.")

            /// Text shown when adding credentials and waiting for authenticvation on another device.
            static let waitingForAuthenticationOnAnotherDevice = NSLocalizedString("AddCredentials.Status.WaitingForAuthenticationOnAnotherDevice", tableName: tableName, bundle: bundle, value: "Waiting for authentication on another device", comment: "Text shown when adding credentials and waiting for authenticvation on another device.")

            /// Text shown when canceling supplementing information.
            static let cancelling = NSLocalizedString("AddCredentials.Status.Canceling", tableName: tableName, bundle: bundle, value: "Canceling…", comment: "Text shown when canceling supplementing information.")

            /// Text shown when submitting supplemental information.
            static let sending = NSLocalizedString("AddCredentials.Status.Sending", tableName: tableName, bundle: bundle, value: "Sending…", comment: "Text shown when submitting supplemental information.")
        }

        enum Warning {
            /// Text for the warning shown when the developer is unverified.
            static let unverifiedClient = NSLocalizedString("AddCredentials.Warning.UnverifiedClient", tableName: tableName, bundle: bundle, value: "Unverified - This solution is only made for development purposes. Do not enter your bank credentials unless you trust the developer.", comment: "Text for the warning shown when the developer is unverified.")
        }

        enum Consent {
            /// Text explaining that when using the service, the user agrees to Tink's Terms and Conditions and Privacy Policy.
            static let serviceAgreement = NSLocalizedString("AddCredentials.Consent.ServiceAgreement", tableName: tableName, bundle: bundle, value: "By using the service, you agree to Tink’s Terms and Conditions and Privacy Policy", comment: "Text explaining that when using the service, the user agrees to Tink's Terms and Conditions and Privacy Policy.")

            /// Title of the Privacy Policy link. This has to match the mention of the Privacy Policy in the `AddCredentials.Consent.ServiceAgreement` string.
            static let privacyPolicy = NSLocalizedString("AddCredentials.Consent.PrivacyPolicy", tableName: tableName, bundle: bundle, value: "Privacy Policy", comment: "Title of the Privacy Policy link. This has to match the mention of the Privacy Policy in the `AddCredentials.Consent.ServiceAgreement` string.")

            /// Title of the Privacy Policy link. This has to match the mention of the Terms and Conditions in the `AddCredentials.Consent.ServiceAgreement` string.
            static let termsAndConditions = NSLocalizedString("AddCredentials.Consent.TermsAndConditions", tableName: tableName, bundle: bundle, value: "Terms and Conditions", comment: "Title of the Privacy Policy link. This has to match the mention of the Terms and Conditions in the `AddCredentials.Consent.ServiceAgreement` string.")

            /// Text explaining that the client will obtain financial information from the current user with a link for more information on which financial information specifically.
            static let financialInformation = NSLocalizedString("AddCredentials.Consent.FinancialInformation", tableName: tableName, bundle: bundle, value: "%@ will obtain some of your financial information. Read More", comment: "Text explaining that the client will obtain financial information from the current user with a link for more information on which financial information specifically.")

            /// Title of the link to more information. This has to match the text for link in the `AddCredentials.Consent.FinancialInformation` string.
            static let readMore = NSLocalizedString("AddCredentials.Consent.ReadMore", tableName: tableName, bundle: bundle, value: "Read More", comment: "Title of the link to more information. This has to match the text for link in the `AddCredentials.Consent.FinancialInformation` string.")
        }
    }

    enum Generic {
        enum Alert {
            /// Title generic alert.
            static let title = NSLocalizedString("Generic.Alert.Title", tableName: tableName, bundle: bundle, value: "Error", comment: "Title generic alert.")

            /// Title for action to dismiss error alert.
            static let dismiss = NSLocalizedString("Generic.Alert.Dismiss", tableName: tableName, bundle: bundle, value: "Dismiss", comment: "Title for action to dismiss error alert.")

            /// Title for action to confirm alert.
            static let ok = NSLocalizedString("Generic.Alert.OK", tableName: tableName, bundle: bundle, value: "OK", comment: "Title for action to confirm alert.")
        }
        enum ServiceAlert {
            /// Title for error alert if error doesn't contain a description.
            static let fallbackTitle = NSLocalizedString("Generic.ServiceAlert.FallbackTitle", tableName: tableName, bundle: bundle, value: "The service is unavailable at the moment.", comment: "Title for error alert if error doesn't contain a description.")

            /// Title for action to retry a failed request.
            static let retry = NSLocalizedString("Generic.ServiceAlert.Retry", tableName: tableName, bundle: bundle, value: "Retry", comment: "Title for action to retry a failed request.")
        }
    }

    enum ProviderPicker {
        enum AccessType {
            /// Title for the group of providers that use Open Banking.
            static let openBankingTitle = NSLocalizedString("ProviderPicker.AccessType.OpenBankingTitle", tableName: tableName, bundle: bundle, value: "Checking accounts", comment: "Title for the group of providers that use Open Banking.")

            /// Text describing the group of providers that use Open Banking.
            static let openBankingDetail = NSLocalizedString("ProviderPicker.AccessType.OpenBankingDetail", tableName: tableName, bundle: bundle, value: "Including everyday accounts, such as your salary account.", comment: "Text describing the group of providers that use Open Banking.")

            /// Title for the group of providers that does not use Open Banking.
            static let otherTitle = NSLocalizedString("ProviderPicker.AccessType.OtherTitle", tableName: tableName, bundle: bundle, value: "Other account types", comment: "Title for the group of providers that does not use Open Banking.")

            /// Text describing the group of providers that does not use Open Banking.
            static let otherDetail = NSLocalizedString("ProviderPicker.AccessType.OtherDetail", tableName: tableName, bundle: bundle, value: "Including saving accounts, credit cards, loans, investments and your personal information.", comment: "Text describing the group of providers that does not use Open Banking.")
        }

        enum Error {
            /// Title for button to try loading providers again.
            static let retryButton = NSLocalizedString("ProviderPicker.Error.RetryButton", tableName: tableName, bundle: bundle, value: "Try again", comment: "Title for button to try loading providers again.")

            /// Title for when providers could not be loaded.
            static let title = NSLocalizedString("ProviderPicker.Error.Title", tableName: tableName, bundle: bundle, value: "We’re sorry, but we couldn't load any banks at the moment", comment: "Title for when providers could not be loaded.")

            /// Description for error when providers could not be loaded and it is likely it's a temporary error.
            static let temporary = NSLocalizedString("ProviderPicker.Error.Temporary", tableName: tableName, bundle: bundle, value: "This could be a temporary error, please try again and see if the problem persists.", comment: "Description for error when providers could not be loaded and it is likely it's a temporary error.")

            /// Description for error when providers could not be loaded.
            static let description = NSLocalizedString("ProviderPicker.Error.Description", tableName: tableName, bundle: bundle, value: "We are informed of this error and are working hard to resolve it. Bear with us, and try again a bit later.", comment: "Description for error when providers could not be loaded.")
        }
        enum List {
            /// Title for screen where user selects which access type to use when adding credentials.
            static let accessTypeTitle = NSLocalizedString("ProviderPicker.List.AccessTypeTitle", tableName: tableName, bundle: bundle, value: "Add %@", comment: "Title for screen where user selects which access type to use when adding credentials.")

            /// Title for screen where user selects which authentication type to use when adding credentials.
            static let credentialTypeTitle = NSLocalizedString("ProviderPicker.List.CredentialsTypeTitle", tableName: tableName, bundle: bundle, value: "Sign in method", comment: "Title for screen where user selects which authentication type to use when adding credentials.")

            /// Title for list of all providers.
            static let financialInstitutionsTitle = NSLocalizedString("ProviderPicker.List.FinancialInstitutionsTitle", tableName: tableName, bundle: bundle, value: "Choose bank", comment: "Title for list of all providers.")

            /// Placeholder in search field shown in provider list.
            static let searchPlaceholder = NSLocalizedString("ProviderPicker.List.SearchPlaceholder", tableName: tableName, bundle: bundle, value: "Search for a bank or card", comment: "Placeholder in search field shown in provider list.")
        }
    }
    enum SupplementalInformation {
        enum Form {
            /// Title for button to send supplemental information when adding credentials.
            static let submit = NSLocalizedString("SupplementalInformation.Form.Submit", tableName: tableName, bundle: bundle, value: "Done", comment: "Title for button to send supplemental information when adding credentials.")

            /// Title for form asking user to supplement information when adding credentials.
            static let title = NSLocalizedString("SupplementalInformation.Form.Title", tableName: tableName, bundle: bundle, value: "Supplemental Information", comment: "Title for form asking user to supplement information when adding credentials.")
        }
    }
    enum ThirdPartyAppAuthentication {

        enum DownloadAlert {
            /// Title for action to cancel downloading app for third-party app authentication.
            static let cancel = NSLocalizedString("ThirdPartyAppAuthentication.DownloadAlert.Cancel", tableName: tableName, bundle: bundle, value: "Cancel", comment: "Title for action to cancel downloading app for third-party app authentication.")

            /// Title for action to confirm alert requesting download of third-party authentication app when AppStore URL could not be opened.
            static let dismiss = NSLocalizedString("ThirdPartyAppAuthentication.DownloadAlert.Dismiss", tableName: tableName, bundle: bundle, value: "OK", comment: "Title for action to confirm alert requesting download of third-party authentication app when AppStore URL could not be opened.")

            /// Title for action to download app for third-party app authentication.
            static let download = NSLocalizedString("ThirdPartyAppAuthentication.DownloadAlert.Download", tableName: tableName, bundle: bundle, value: "Download", comment: "Title for action to download app for third-party app authentication.")
        }
    }
}


