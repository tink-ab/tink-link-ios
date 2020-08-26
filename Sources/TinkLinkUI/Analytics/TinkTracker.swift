import Foundation

class TinkLinkTracker {

    var isTest: Bool = false
    var userID: String? = nil
    var credentialsID: String?

    private let clientID: String
    private let flow: AnalyticsFlow
    private let sessionID = UUID().uuidString
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
            self.flow = .credentialsAuthenticate
            self.credentialsID = id.value
        case .create(providerPredicate: let predicate):
            self.flow = .credentialsAdd
            self.credentialsID = nil
            if case .kinds(let kinds) = predicate {
                isTest = kinds.contains(.test)
            }
        case .refresh(credentialsID: let id):
            self.flow = .credentialsRefresh
            self.credentialsID = id.value
        case .update(credentialsID: let id):
            self.flow = .credentialsAuthenticate
            self.credentialsID = id.value
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

