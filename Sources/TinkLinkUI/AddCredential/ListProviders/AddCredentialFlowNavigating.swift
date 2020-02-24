import UIKit
import TinkLink

protocol AddCredentialFlowCoordinating: AnyObject { 
    func showScopeDescriptions()
    func showWebContent(with url: URL)
    func addCredential(provider: Provider, form: Form, allowAnotherDevice: Bool)
}
