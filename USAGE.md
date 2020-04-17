# Usage Examples

This document outlines how to use the different classes and types provided by Tink Link.

## Users

### Authenticating permanent users

> Creating permanent users is limited to our Enterprise customers.

1. If you directly use access tokens, you can authenticate your permanent user as follows:

```swift
let userContext = UserContext()
let userCanceller = userContext.authenticateUser(accessToken: <#Access Token#>, completion: { result in
    do {
        let user = try result.get()
        let providerContext = ProviderContext(user: user)
        <#Code using providerContext#>
    } catch {
        <#Error Handling#>
    }
})
```

2. If you use delegation to create an authorization code, you can authenticate your permanent user with the authorization code as follows:

```swift
let userContext = UserContext()
let userCanceller = userContext.authenticateUser(authorizationCode: <#AuthorizationCode#>, completion: { result in
    do {
        let user = try result.get()
        let providerContext = ProviderContext(user: user)
        <#Code using providerContext#>
    } catch {
        <#Error Handling#>
    }
})
```

### Creating temporary users

Temporary users are not currently supported in Tink Link, hence Tink Link can only be used by Enterprise customers that are able to create permanent users.

## Selecting providers

### Listing providers

To be able to fetch providers, you will first need to have an authenticated user in Tink Link. Here is an example how to list all providers with a `UITableViewController` subclass.

```swift
class ProviderListViewController: UITableViewController {
    private var providerContext: ProviderContext?
    private let userContext = UserContext()

    private var financialInstitutionGroupNodes: [ProviderTree.FinancialInstitutionGroupNode] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        userContext.authenticateUser(accessToken: <#Access Token#>, completion: { result in
            do {
                let user = try result.get()
                self?.providerContext = ProviderContext(user: user)
                self?.providerContext?.fetchProviders(completion: { [weak self] result in
                    DispatchQueue.main.async {
                        do {
                            let providers = try result.get()
                            self?.financialInstitutionGroupNodes = ProviderTree(providers: providers).financialInstitutionGroups
                        } catch {
                            <#Error Handling#>
                        }
                    }
                })
            } catch {
                <#Error Handling#>
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return financialInstitutionGroupNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let providerGroup = financialInstitutionGroupNodes[indexPath.row]
        cell.textLabel?.text = providerGroup.displayName
        return cell
    }
}
```

### Navigating provider groups

Use the `ProviderTree` to group providers by financial institution, access type and credentials kind.

```swift
let providerTree = ProviderTree(providers: <#T##Providers#>)
```

Handle selection of a provider group by switching on the group itself to determine which screen in the provider hierarchy should be shown next.

```swift
override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let financialInstitutionGroupNode = financialInstitutionGroupNodes[indexPath.row]
    switch financialInstitutionGroupNode {
    case .financialInstitutions(let financialInstitutionGroups):
        showFinancialInstitution(for: financialInstitutionGroups, title: financialInstitutionGroupNode.displayName)
    case .accessTypes(let accessTypeGroups):
        showAccessTypePicker(for: accessTypeGroups, title: financialInstitutionGroupNode.displayName)
    case .credentialsKinds(let groups):
        showCredentialsKindPicker(for: groups)
    case .provider(let provider):
        showAddCredentials(for: provider)
    }
}
```

## Adding credentials

### Creating and updating a form

A `Form` is used to represent what a user needs to input in order to proceed. For example, it could be a username and a password field or a field to enter a OTP.

Here's how to create a form for a selected provider:

```swift
var form = Form(provider: <#Provider#>)
var textFields = [UITextField]()
...
for field in form.fields {
    let textField = UITextField()
    textField.placeholder = field.attributes.placeholder
    textField.isSecureTextEntry = field.attributes.isSecureTextEntry
    textField.isEnabled = field.attributes.isEditable
    textField.text = field.text
    <#Add to view#>

    textFields.add(textField)
}
```

To update the respective form fields with the user entered values:

```swift
for (index, textField) in textFields.enumerated() {
    form.fields[index].text = textField.text
}
```

Alternatively you can also use the custom subscript to access the fields using their respective `name` value.

```swift
form.fields[name: "username"]?.text = <#String#>
form.fields[name: "password"]?.text = <#String#>
```

### Form validation

Make sure to validate the entered data before submitting a request to add credentials or supplement information.

Use `areFieldsValid` to verify if all form fields are valid. For example, you can use this to enable a submit button when the text fields change and the entered values are valid.

```swift
@objc func textFieldDidChange(_ notification: Notification) {
    submitButton.isEnabled = form.areFieldsValid
}
```

Use `validateFields()` to validate all fields. If not valid, it will throw an error that contains more information about which fields are not valid and why.

```swift
do {
    try form.validateFields()
} catch let error as Form.Fields.ValidationError {
    if let usernameFieldError = error[fieldName: "username"] {
        usernameValidationErrorLabel.text = usernameFieldError.errorDescription
    }
}
```

### Add credentials with form fields

To add a credential for the current user, call `addCredentials` with the provider you want to add a credential for and a form with valid field values. Make sure to handle the status changes in the `progressHandler` closure and the `result` in the completion handler.

```swift
credentialsContext.addCredentials(for: provider, form: form, progressHandler: { status in
    switch status {
    case .awaitingSupplementalInformation(let supplementInformationTask):
        <#Present form for supplemental information task#>
    case .awaitingThirdPartyAppAuthentication(let thirdPartyAppAuthentication):
        <#Open third party app deep link URL#>
    default:
        break
    }
}, completion: { result in
    <#Handle result#>
}
```

### Handling awaiting supplemental information

Supplemental information is used to prompt the user to enter any further information during the process of adding credentials (such as two factor authentication challenges). When the `progressHandler` emits a `awaitingSupplementalInformation` status you need to prompt the user to enter the required information. To do that, you can once again create a form for the given credentials and present it to the user. The credentials can be retrieved from the `SupplementInformationTask`.

```swift
let form = Form(credentials: supplementInformationTask.credentials)
form.fields[0].text = <#String#>
form.fields[1].text = <#String#>
```

Submit the entered supplemental information after validation as follows:

```swift
do {
    try form.validateFields()
    supplementInformationTask.submit(form)
} catch {
    <#Handle error#>
}
```

After submitting the form, further status updates will once again be sent to the `progressHandler` in the existing `addCredentials` call.

### Handling third party app authentication

Third party authentication is used to handle authentication outside of your app (such as app-to-app and app-to-web redirects). When the `progressHandler` emits a `awaitingThirdPartyAppAuthentication` status, you should let the `ThirdPartyAppAuthenticationTask` object handle the update like this:

```swift
/// thirdPartyAppAuthenticationTask.handle()
```

If the third party authentication couldn't be handled by the `ThirdPartyAppAuthenticationTask`, you need to handle the `AddCredentialsTask` completion result and check for a `ThirdPartyAppAuthenticationTask.Error`. This error can tell you if the user needs to download the thirdparty authentication app.

Here is how you can prompt the user to download the third party app if it is not currently installed on the device:

```swift
let alertController = UIAlertController(title: thirdPartyAppAuthentication.downloadTitle, message: thirdPartyAppAuthentication.downloadMessage, preferredStyle: .alert)

if let appStoreURL = thirdPartyAppAuthentication.appStoreURL, UIApplication.shared.canOpenURL(appStoreURL) {
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    let downloadAction = UIAlertAction(title: "Download", style: .default, handler: { _ in
        UIApplication.shared.open(appStoreURL)
    })
    alertController.addAction(cancelAction)
    alertController.addAction(downloadAction)
} else {
    let okAction = UIAlertAction(title: "OK", style: .default)
    alertController.addAction(okAction)
}

present(alertController, animated: true)
```

After the redirect to the third party app, some providers require additional information from the authentication to be sent back to Tink after the user authenticates within the third party app, for the credentials to be added successfully. This information is returned to your app through the redirect URI. Use the `open` method in your `UIApplicationDelegate` to let Tink Link send the information back to Tink if needed.

```swift
func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return Tink.shared.open(url)
}
```

### Handling Universal Links

For some providers the redirect needs to be a `https` link. Use the continue user activity method in your `UIApplicationDelegate` to let Tink Link send the information back to Tink if needed.

```swift
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
        return Tink.shared.open(url)
    } else {
        return false
    }
}
```

## Displaying user consent

If you are aggregating data under Tink's license, the user must be informed and fully understand what kind of data will be aggregated. This requires you to display the necessary consent information based on the types of access scopes you will be requesting.

Here is how you can retrieve the scopes and their descriptions:

```swift
let authorizationContext = AuthorizationContext(user: user)
let scopes: [Scope] = [
    .transactions(.read),
    .accounts(.read)
]

authorizationContext.scopeDescriptions(scopes: scopes) { [weak self] result in
    DispatchQueue.main.async {
        do {
            self?.scopeDescriptions = try result.get()
            print(self?.scopeDescriptions[0].title)
            print(self?.scopeDescriptions[0].description)
        } catch {
            <#Error Handling#>
        }
    }
}
```

## Displaying Terms and Conditions and Privacy Policy

If you are aggregating data under Tink's license, the user must be presented with an option to view Tink’s Terms and Conditions and Privacy Policy before any data is aggregated.

Here is how you can get the URL for the Terms and Conditions and present it with `SFSafariViewController`.

```swift
import SafariServices

func showTermsAndConditions() {
    let url = authorizationContext.termsAndConditions(locale: <#appLocale#>)
    let safariViewController = SFSafariViewController(url: url)
    present(safariViewController, animated: true)
}

func showPrivacyPolicy() {
    let url = authorizationContext.privacyPolicy(locale: <#appLocale#>)
    let safariViewController = SFSafariViewController(url: url)
    present(safariViewController, animated: true)
}
```

## Advanced usage

In some cases, you may want to have multiple `Tink` instances. You can create multiple `Tink` instance as follows:

```swift
let configuration = Tink.Configuration(clientID: <#T##String#>, redirectURI: <#T##URL#>)
let customTink = Tink(configuration: configuration)
```

## How to display Tink Link

1. Import Tink Link UI
```swift
import TinkLinkUI
```

2. First you need to define what scopes you need.

```swift
let scopes: [Scope] = [
    .accounts(.read), 
    .transactions(.read)
]
```

3. Then create a `TinkLinkViewController` with a market and the scopes to use.

```swift
let tinkLinkViewController = TinkLinkViewController(market: <#String#>, scopes: scopes) { result in 
    do {
        let authorizationCode = try result.get()
        // Exchange the authorization code for a access token.
    } catch {
        // Handle any errors
    }
}
```

4. Tink Link is designed to be presented modally so display the view controller by calling `present(_:animated:)`

```swift
present(tinkLinkViewController, animated: true)
```
