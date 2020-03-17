# Usage Examples

## Users

### Permanent user
Creating permanent users is limited to our Enterprise customers.
1. If you use the access token directly, you can authenticate your permanent user and use it in a `ProviderContext` like this:
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
2. If you delegate the access token with Tink, then you can authenticate your permanent user with the authorization code like this: 
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
Currently, only Enterprise customers that can create permanent users are able to use Tink Link.

## How to list and select providers

### Listing and responding to changes

As mentioned at the first section, before fetching providers, you need to have a permanent user via Tink Link first, then use it to fetch the providers. 
Here's how you can list all providers with a `UITableViewController` subclass.  

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

### Provider groups

Use the `ProviderTree` to group providers by financial institution, access type and credential kind.
```swift
let providerTree = ProviderTree(providers: <#T##Providers#>)
```

Handle selection of a provider group by switching on the group to decide which screen should be shown next.

```swift
override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let financialInstitutionGroupNode = financialInstitutionGroupNodes[indexPath.row]
    switch financialInstitutionGroupNode {
    case .financialInstitutions(let financialInstitutionGroups):
        showFinancialInstitution(for: financialInstitutionGroups, title: financialInstitutionGroupNode.displayName)
    case .accessTypes(let accessTypeGroups):
        showAccessTypePicker(for: accessTypeGroups, title: financialInstitutionGroupNode.displayName)
    case .credentialKinds(let groups):
        showCredentialKindPicker(for: groups)
    case .provider(let provider):
        showAddCredential(for: provider)
    }
}
```

## Add credential

### Creating and updating a form

A `Form` is used to determine what a user needs to input in order to proceed. For example it could be a username and a password field.

Here's how to create a form for a provider with a username and password field and how to update the fields.

```swift
var form = Form(provider: <#Provider#>)
form.fields[name: "username"]?.text = <#String#>
form.fields[name: "password"]?.text = <#String#>
...
```

### Configuring UITextFields from form fields

```swift
for field in form.fields {
    let textField = UITextField()
    textField.placeholder = field.attributes.placeholder
    textField.isSecureTextEntry = field.attributes.isSecureTextEntry
    textField.isEnabled = field.attributes.isEditable
    textField.text = field.text
    <#Add to view#>
}
```

### Form validation

Validate before you submit a request to add credential or supplement information.

Use `areFieldsValid` to check if all form fields are valid. For example, you can use this to enable a submit button when text fields change.

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

### Add Credential with form fields

To add a credential for the current user, call `addCredential` with the provider you want to add a credential for and a form with valid fields for that provider.
Then handle status changes in the `progressHandler` closure and the `result` from the completion handler.

```swift
credentialContext.addCredential(for: provider, form: form, progressHandler: { status in
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

Creates a form for the given credential. Usually you get the credential from `SupplementInformationTask`.

```swift
let form = Form(credential: supplementInformationTask.credential)
form.fields[0].text = <#String#>
form.fields[1].text = <#String#>
```

Submit update supplement information after validating like this:

```swift
do {
    try form.validateFields()
    supplementInformationTask.submit(form)
} catch {
    <#Handle error#>
}
```

After submitting the form new status updates will sent to the `progressHandler` in the `addCredential` call.

### Handling third party app authentication

When `progressHandler` get a `awaitingThirdPartyAppAuthentication` status you need to try to open the url provided by `ThirdPartyAppAuthentication`. Check if the system can open the url or ask the user to download the app like this:

```swift
if let deepLinkURL = thirdPartyAppAuthentication.deepLinkURL, UIApplication.shared.canOpenURL(deepLinkURL) {
    UIApplication.shared.open(deepLinkURL)
} else {
    <#Ask user to download app#>
}
```

Here's how you can ask the user to download the third party app via an alert:

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

After the redirect to the third party app, some providers requires additional information to be sent to Tink after the user authenticates with the third party app for the credential to be added successfully. This information is passed to your app via the redirect URI. Use the open method in your `UIApplicationDelegate` to let `Tink` send the information to Tink if needed.
```swift
func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return Tink.shared.open(url)
}
```

### Handling Universal Links
For some providers the redirect needs to be a https link. Use the continue user activity method in your `UIApplicationDelegate` to let `Tink` send the information to Tink if needed.

```swift
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
        return Tink.shared.open(url)
    } else {
        return false
    }
}
```

## Showing Terms and Conditions and Privacy Policy
If aggregating under Tink's license the user must be presented with an option to view Tink’s Terms and Conditions and Privacy Policy before aggregating any data.

Here's how you can get the url for the Terms and Conditions and present it with the SFSafariViewController.

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
In some cases, you may want to have multiple `Tink` instances, you can create your custom `Tink` instance like this:

```swift
let configuration = Tink.Configuration(clientID: <#T##String#>, redirectURI: <#T##URL#>)
let customTink = Tink(configuration: configuration)
```
