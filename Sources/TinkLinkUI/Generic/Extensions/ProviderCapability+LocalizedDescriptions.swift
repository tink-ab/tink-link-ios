import Foundation
import TinkLink

extension Provider.Capabilities {
    var localizedDescriptions: [String] {
        var descriptions = [String]()
        if contains(.transfers) {
            descriptions.append(Strings.ProviderPicker.Capability.transfers)
        }
        if contains(.mortgageAggregation) {
            descriptions.append(Strings.ProviderPicker.Capability.mortgageAggregation)
        }
        if contains(.checkingAccounts) {
            descriptions.append(Strings.ProviderPicker.Capability.checkingAccounts)
        }
        if contains(.savingsAccounts) {
            descriptions.append(Strings.ProviderPicker.Capability.savingsAccounts)
        }
        if contains(.creditCards) {
            descriptions.append(Strings.ProviderPicker.Capability.creditCards)
        }
        if contains(.investments) {
            descriptions.append(Strings.ProviderPicker.Capability.investments)
        }
        if contains(.loans) {
            descriptions.append(Strings.ProviderPicker.Capability.loans)
        }
        if contains(.payments) {
            descriptions.append(Strings.ProviderPicker.Capability.payments)
        }
        if contains(.mortgageLoan) {
            descriptions.append(Strings.ProviderPicker.Capability.mortgageLoan)
        }
        if contains(.identityData) {
            descriptions.append(Strings.ProviderPicker.Capability.identityData)
        }
        if contains(.eInvoices) {
            descriptions.append(Strings.ProviderPicker.Capability.eInvoices)
        }
        return descriptions
    }
}
