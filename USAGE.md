# Usage Examples

## Users

### Permanent user
Creating permanent users in Tink is limited to our Enterprise customers. 

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
Currently, only Enterprise customers that can create permanent users are able to use the Headless TinkLink SDK.

## Listing providers

As mentioned at the first section, before fetching providers, you need to have a permanent user via TinkLink first, then use it to fetch the providers. 
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

## Adding a Credentials

To add a credentials for the current user, call `addCredentials` with the provider you want to add a credentials for and a form with valid fields for that provider.
Then handle status changes in the `progressHandler` closure and the `result` from the completion handler.

```swift
credentialContext.addCredentials(for: provider, form: form, progressHandler: { status in
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

Create a form for the provided credentials.

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

When progressHandler get a `awaitingThirdPartyAppAuthentication` status you need to try to open the url provided by `ThirdPartyAppAuthentication`. Check if the system can open the url or ask the user to download the app like this:

```swift
if let deepLinkURL = thirdPartyAppAuthentication.deepLinkURL, UIApplication.shared.canOpenURL(deepLinkURL) {
    UIApplication.shared.open(deepLinkURL)
} else {
    <#Ask user to download app#>
}
```

After the redirect to the third party app, some providers requires additional information to be sent to Tink after the user authenticates with the third party app for the credentials to be added successfully. This information is passed to your app via the redirect URI. Use the open method in your `UIApplicationDelegate` to let TinkLink send the information to Tink if needed.

```swift
func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return TinkLink.shared.open(url)
}
```

### Handling Universal Links
For some providers the redirect needs to be a https link. Use the continue user activity method in your `UIApplicationDelegate` to let TinkLink send the information to Tink if needed.

```swift
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
        return TinkLink.shared.open(url)
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
