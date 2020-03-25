# Localizable Strings

All strings in TinkLinkUI are by default in English. To localize the strings in your app you can provide your own strings by specifying strings for a specific set of keys in a strings file named `TinkLink`.

For example: To add a Italian translation for the retry button displayed if providers couldn't load, add `"ProviderPicker.Error.RetryButton" = "Riprova";` to your `it.lproj/TinkLink.strings` file in your app bundle.
Then the SDK will use that string instead of the default ones when running on a device that has the language setting set to prefer Italian.

## Add Credentials

| Key | Default | Description |
| -------- | -------- | -------- |
| AddCredentials.Consent.FinancialInformation | %@ will obtain some of your financial information. Read More | Text explaining that the client will obtain financial information of the|  current user with a link for more information on which financial information.
| AddCredentials.Consent.PrivacyPolicy | Privacy Policy | Title of the Privacy Policy link. This has to match the mention of the Privacy Policy in the AddCredentials.Consent.ServiceAgreement string.
| AddCredentials.Consent.ReadMore | Read More | Title of the link to more information. This has to match the text for link in the AddCredentials.Consent.FinancialInformation string.
| AddCredentials.Consent.ServiceAgreement | By using the service, you agree to Tink’s Terms and Conditions and Privacy Policy | Text explaining that when using the service, the user agrees to Tink's Terms and Conditions and Privacy Policy.
| AddCredentials.Consent.TermsAndConditions | Terms and Conditions | Title of the Privacy Policy link. This has to match the mention of the Terms and Conditions in the AddCredentials.Consent.ServiceAgreement string.
| AddCredentials.Discard.ContinueAction | Continue Editing | Title for action to continue adding credentials.
| AddCredentials.Discard.PrimaryAction | Discard Changes | Title for action to discard adding credentials.
| AddCredentials.Discard.Title | Are you sure you want to discard this new credential? | Title for action sheet presented when user tries to dismiss modal while adding credentials.
| AddCredentials.Form.Continue | Continue | Title for button to start authenticating credentials.
| AddCredentials.Form.OpenBankID | Open BankID | Title for button to open BankID app.
| AddCredentials.Form.Title | Authenticate | Title for screen where user fills in form to add credentials.
| AddCredentials.Progress.Authorizing | Authorizing… | Text shown when adding credentials and waiting for authorization.
| AddCredentials.Progress.Canceling | Canceling… | Text shown when canceling supplementing information.
| AddCredentials.Progress.Sending | Sending… | Text shown when submitting supplemental information.
| AddCredentials.Progress.WaitingForAuthenticationOnAnotherDevice | Waiting for authentication on another device | Text shown when adding credentials and waiting for authenticvation on another device.
| AddCredentials.ScopeDescriptions.Body | By following through this service, we’ll collect financial data from you. These are the data points we will collect from you: | Text introducing the descriptions for which data points will be collected when using the service.
| AddCredentials.ScopeDescriptions.Title | We’ll collect the following data from you | Title for text introducing the descriptions for which data points will be collected when using the service.
| AddCredentials.Status.Cancel | Cancel | Title for button to cancel an ongoing task for adding credentials.
| AddCredentials.SuccessfullyAdded.Done | Done | Title for button to dismiss the screen shown when credentials were successfully added.
| AddCredentials.SuccessfullyAdded.Subtitle | Your account has successfully connected to %@. You'll be redirected back in a few seconds... | Subtitle for screen shown when credentials were successfully added.
| AddCredentials.SuccessfullyAdded.Title | Connection successful | Title for screen shown when credentials were successfully added.
| AddCredentials.SupplementalInformation.Cancel | Done | Title for button to send supplemental information when adding credentials.
| AddCredentials.SupplementalInformation.Title | Supplemental Information | Title for form asking user to supplement information when adding credentials.

## Add Credentials Task

| Key | Default | Description |
| -------- | -------- | -------- |
| AddCredentialsTask.Error.AuthenticationFailed | Authentication failed | Title for error shown when authentication failed while adding credentials.
| AddCredentialsTask.Error.CredentialsAlreadyExists | Error | Title for error shown when credentials already exists.
| AddCredentialsTask.Error.CredentialsAlreadyExists.FailureReason | You already have a connection to this bank or service. | Message for error shown when credentials already exists.
| AddCredentialsTask.Error.Description | We are informed of this error and are working hard to resolve it. Bear with us, and try again a bit later. | Description for error when providers could not be loaded.
| AddCredentialsTask.Error.PermanentFailure | Permanent error | Title for error shown when a permanent failure occured while adding credentials.
| AddCredentialsTask.Error.TemporaryFailure | Temporary error | Title for error shown when a temporary failure occured while adding credentials.

## Generic

| Key | Default | Description |
| -------- | -------- | -------- |
| Generic.Alert.Dismiss | Dismiss | Title for action to dismiss error alert.
| Generic.Alert.OK | OK | Title for action to confirm alert.
| Generic.Alert.Title | Error | Title generic alert.
| Generic.ServiceAlert.FallbackTitle | The service is unavailable at the moment. | Title for error alert if error doesn't contain a description.
| Generic.ServiceAlert.Retry | Retry | Title for action to retry a failed request.

| Key | Default | Description |
| -------- | -------- | -------- |
| ProviderPicker.Error.RetryButton | Try again | Title for button to try loading providers again.
| ProviderPicker.Error.Temporary | This could be a temporary error, please try again and see if the problem persists. | Description for error when providers could not be loaded and it is likely it's a temporary error.
| ProviderPicker.Error.Title | We’re sorry, but we couldn't load any banks at the moment | Title for when providers could not be loaded.
| ProviderPicker.Search.Placeholder | Search for a bank or card | Placeholder in search field shown in provider list.

## Third-Party App Authentication
| Key | Default | Description |
| -------- | -------- | -------- |
| ThirdPartyAppAuthentication.DownloadAlert.Cancel | Cancel | Title for action to cancel downloading app for third-party app authentication.
| ThirdPartyAppAuthentication.DownloadAlert.Dismiss | OK | Title for action to confirm alert requesting download of third-party authentication app when AppStore URL could not be opened.
| ThirdPartyAppAuthentication.DownloadAlert.Download | Download | Title for action to download app for third-party app authentication.
