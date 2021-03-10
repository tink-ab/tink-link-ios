import UIKit

class TinkLinkTracker {
    private struct AppInfo {
        let bundleID: String?
        let name: String?
        let version: String?
    }

    var userID: String?
    var market: String?
    var providerID: String?
    var credentialsID: String?

    private let clientID: String
    private let flow: AnalyticsFlow
    private let sessionID = UUID().uuidString
    private let isTest: Bool

    private let version: String = {
        if let infoDictionary = Bundle(for: TinkLinkTracker.self).infoDictionary,
           let shortVersion = infoDictionary["CFBundleShortVersionString"] as? String {
            return shortVersion
        } else {
            return "-"
        }
    }()

    private let appInfo: AppInfo = {
        let bundleIdentifier = Bundle.main.bundleIdentifier
        let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return AppInfo(bundleID: bundleIdentifier, name: appName, version: appVersion)
    }()

    private let product = "CREDENTIALS" // Can only be credentials right now.
    private let platform = "IOS"
    private let device = "MOBILE"

    private let api = AnalyticsAPI()

    init(clientID: String, operation: TinkLinkViewController.Operation, market: String?) {
        self.clientID = clientID
        self.market = market

        switch operation.value {
        case .authenticate(credentialsID: let id):
            self.flow = .credentialsAuthenticate
            self.credentialsID = id.value
            self.isTest = false

        case .create(providerPredicate: let predicate, _):
            self.flow = .credentialsAdd
            self.credentialsID = nil
            if case .kinds(let kinds) = predicate.value {
                isTest = kinds.contains(.test)
            } else {
                self.isTest = false
            }

        case .refresh(credentialsID: let id, _):
            self.flow = .credentialsRefresh
            self.credentialsID = id.value
            self.isTest = false

        case .update(credentialsID: let id):
            self.flow = .credentialsUpdate
            self.credentialsID = id.value
            self.isTest = false
        }
    }

    func trackClose(from viewController: UIViewController) {
        switch viewController.self {
        case is ProviderListViewController:
            track(interaction: .close, screen: .providerSelection)
        case is FinancialInstitutionPickerViewController:
            track(interaction: .close, screen: .financialInstitutionSelection)
        case is CredentialsKindPickerViewController:
            track(interaction: .close, screen: .credentialsTypeSelection)
        case is FinancialServicesTypePickerViewController:
            track(interaction: .close, screen: .authenticationUserTypeSelection)
        case is AccessTypePickerViewController:
            track(interaction: .close, screen: .accessTypeSelection)
        case is CredentialsFormViewController:
            track(interaction: .close, screen: .submitCredentials)
        case is CredentialsSuccessfullyAddedViewController:
            track(interaction: .close, screen: .success)
        default:
            break
        }
    }

    func track(interaction: InteractionEvent, screen: ScreenEvent) {
        guard let userID = userID else {
            return
        }
        let request = TinkAnalyticsRequest.interactionEvent(.init(
            appName: appInfo.name,
            appIdentifier: appInfo.bundleID,
            appVersion: appInfo.version,
            market: market,
            clientId: clientID,
            sessionId: sessionID,
            userId: userID,
            providerName: providerID,
            credentialsId: credentialsID,
            label: nil,
            view: screen.rawValue,
            timestamp: Date(),
            product: product,
            action: "\(screen.rawValue)/\(interaction.rawValue)",
            device: device
        )
        )
        api.sendRequest(request)
    }

    func track(screen: ScreenEvent) {
        guard let userID = userID else {
            return
        }
        let request = TinkAnalyticsRequest.viewEvent(.init(
            appName: appInfo.name,
            appIdentifier: appInfo.bundleID,
            appVersion: appInfo.version,
            market: market,
            clientId: clientID,
            sessionId: sessionID,
            isTest: isTest,
            product: product,
            version: version,
            platform: platform,
            device: device,
            userId: userID,
            providerName: providerID,
            credentialsId: credentialsID,
            flow: flow.rawValue,
            view: screen.rawValue,
            timestamp: Date()
        )
        )
        api.sendRequest(request)
    }

    func track(applicationEvent: ApplicationEvent) {
        guard let userID = userID else {
            return
        }
        let request = TinkAnalyticsRequest.applicationEvent(
            .init(
                appName: appInfo.name,
                appIdentifier: appInfo.bundleID,
                appVersion: appInfo.version,
                market: market,
                clientId: clientID,
                sessionId: sessionID,
                isTest: isTest,
                product: product,
                version: version,
                platform: platform,
                device: device,
                userId: userID,
                providerName: providerID,
                credentialsId: credentialsID,
                flow: flow.rawValue,
                type: applicationEvent.rawValue,
                timestamp: Date()
            )
        )
        api.sendRequest(request)
    }
}
