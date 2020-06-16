import Foundation

extension TransferDestination {
    init(restTransferDestination destination: RESTTransferDestination) {
        self.balance = destination.balance
        self.displayAccountNumber = destination.displayAccountNumber
        self.displayBankName = destination.displayBankName
        self.kind = destination.type.flatMap { TransferDestination.Kind(restTransferDestinationType: $0) } ?? .unknown
        self.isMatchingMultipleDestinations = destination.matchesMultiple
        self.name = destination.name
        self.uri = destination.uri.flatMap { URL(string: $0) }
    }
}

extension TransferDestination.Kind {
    init(restTransferDestinationType type: RESTTransferDestination.ModelType) {
        switch type {
        case .checking: self = .checking
        case .creditCard: self = .creditCard
        case .external: self = .external
        case .investment: self = .investment
        case .loan: self = .loan
        case .savings: self = .savings
        case .unknown: self = .unknown
        }
    }
}
