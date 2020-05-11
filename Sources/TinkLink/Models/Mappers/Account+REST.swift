import Foundation

extension Account {
    init(restAccount account: RESTAccount) {
        self.accountNumber = account.accountNumber
        self.balance = account.balance
        self.credentialsID = Credentials.ID(account.credentialsId)
        self.isFavored = account.favored
        self.id = Account.ID(account.id)
        self.name = account.name
        self.ownership = account.ownership
        self.kind = Account.Kind(restAccountType: account.type)
        self.identifiers = account.identifiers.flatMap { Transfer.TransferEntityURI($0) }
        self.transferDestinations = account.transferDestinations?.compactMap { TransferDestination(restTransferDestination: $0) }
        self.details = account.details.flatMap { AccountDetails(restAccountDetails: $0) }
        self.holderName = account.holderName
        self.isClosed = account.closed
        self.flag = account.flags.flatMap { Account.Flag(restAccountFlags: $0) }
        self.accountExclusion = Account.AccountExclusion(restAccountExclusion: account.accountExclusion)
        self.currencyDenominatedBalance = account.currencyDenominatedBalance.flatMap { CurrencyDenominatedAmount(restCurrencyDenominatedAmount: $0) }
        self.refreshed = account.refreshed
        self.financialInstitutionID = account.financialInstitutionId.flatMap { Provider.FinancialInstitution.ID($0) }
    }
}

extension Account.Kind {
    init(restAccountType type: RESTAccount.ModelType) {
        switch type {
        case .checking: self = .checking
        case .savings: self = .savings
        case .investment: self = .investment
        case .mortgage: self = .mortgage
        case .creditCard: self = .creditCard
        case .loan: self = .loan
        case .pension: self = .pension
        case .other: self = .other
        case .external: self = .external
        }
    }
}

extension Account.Flag {
    init(restAccountFlags flags: RESTAccount.Flags) {
        switch flags {
        case .business: self = .business
        case .mandate: self = .mandate
        }
    }
}

extension Account.AccountExclusion {
    init?(restAccountExclusion exclusion: RESTAccount.AccountExclusion) {
        switch exclusion {
        case .aggregation: self = .aggregation
        case .pfmAndSearch: self = .pfmAndSearch
        case .pfmData: self = .pfmData
        case ._none: return nil
        }
    }
}
