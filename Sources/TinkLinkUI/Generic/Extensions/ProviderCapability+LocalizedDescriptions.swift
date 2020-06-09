import Foundation
import TinkLink

extension Provider.Capabilities {
    var localizedDescriptions: [String] {
        var descriptions = [String]()
        if contains(.transfers) {
            descriptions.append(Strings.ProviderCapability.transfers)
        }
        if contains(.mortgageAggregation) {
            descriptions.append(Strings.ProviderCapability.mortgageAggregation)
        }
        if contains(.checkingAccounts) {
            descriptions.append(Strings.ProviderCapability.checkingAccounts)
        }
        if contains(.savingsAccounts) {
            descriptions.append(Strings.ProviderCapability.savingsAccounts)
        }
        if contains(.creditCards) {
            descriptions.append(Strings.ProviderCapability.creditCards)
        }
        if contains(.investments) {
            descriptions.append(Strings.ProviderCapability.investments)
        }
        if contains(.loans) {
            descriptions.append(Strings.ProviderCapability.loans)
        }
        if contains(.payments) {
            descriptions.append(Strings.ProviderCapability.payments)
        }
        if contains(.mortgageLoan) {
            descriptions.append(Strings.ProviderCapability.mortgageLoan)
        }
        if contains(.identityData) {
            descriptions.append(Strings.ProviderCapability.identityData)
        }
        if contains(.eInvoices) {
            descriptions.append(Strings.ProviderCapability.eInvoices)
        }
        return descriptions
    }
}
