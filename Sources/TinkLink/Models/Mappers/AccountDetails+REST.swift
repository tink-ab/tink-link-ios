import Foundation

extension AccountDetails {
    init(restAccountDetails accountDetails: RESTAccountDetails) {
        self.interest = accountDetails.interest
        self.kind = accountDetails.type.flatMap { AccountDetails.Kind(restAccountDetailsType: $0) } ?? .unknown
        self.nextDayOfTermsChange = accountDetails.nextDayOfTermsChange
        self.numberOfMonthsBound = accountDetails.numMonthsBound
    }
}

extension AccountDetails.Kind {
    init(restAccountDetailsType type: RESTAccountDetails.ModelType) {
        switch type {
        case .mortgage: self = .mortgage
        case .blanco: self = .blanco
        case .membership: self = .membership
        case .vehicle: self = .vehicle
        case .land: self = .land
        case .student: self = .student
        case .credit: self = .credit
        case .other: self = .other
        case .unknown: self = .unknown
        }
    }
}
