import Foundation

class TinkLinkTracker {

    var userID: String? = nil

    private let credentialsID: String?
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
    private let product = "CREDENTIALS" // Can only be credentials right now.
    private let platform = "IOS"
    private let device = "MOBILE"

    private let api = AnalyticsAPI()

    init(clientID: String, operation: TinkLinkViewController.Operation) {
        self.clientID = clientID

        switch operation {
        case .authenticate(credentialsID: let id):
            flow = .credentialsAuthenticate
            credentialsID = id.value
            isTest = false

        case .create(providerPredicate: let predicate):
            flow = .credentialsAdd
            credentialsID = nil
            if case .kinds(let kinds) = predicate {
                isTest = kinds.contains(.test)
            } else {
                isTest = false
            }

        case .refresh(credentialsID: let id):
            flow = .credentialsRefresh
            credentialsID = id.value
            isTest = false

        case .update(credentialsID: let id):
            flow = .credentialsUpdate
            credentialsID = id.value
            isTest = false
        }
    }

    func send(event: InteractionEvent, view: ScreenEvent) {
        guard let userID = userID else {
            return
        }
        let request = TinkAnalyticsRequest.interactionEvent(.init(
            clientId: clientID,
            sessionId: sessionID,
            userId: userID,
            label: nil,
            view: view.rawValue,
            timestamp: Date(),
            product: product,
            action: event.rawValue,
            device: device)
        )
        api.sendRequest(request)
    }

    func send(event: ScreenEvent) {
        guard let userID = userID else {
            return
        }
        let request = TinkAnalyticsRequest.viewEvent(.init(
            clientId: clientID,
            sessionId: sessionID,
            isTest: isTest,
            product: product,
            version: version,
            platform: platform,
            device: device,
            userId: userID,
            flow: flow.rawValue,
            view: event.rawValue,
            timestamp: Date())
        )
        api.sendRequest(request)
    }
}

