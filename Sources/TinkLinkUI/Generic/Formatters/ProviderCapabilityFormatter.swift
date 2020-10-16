import Foundation
import TinkLink

final class ProviderCapabilityFormatter: Formatter {
    var formattingContext: Formatter.Context = .unknown

    let listFormatter = HumanEnumeratedFormatter()

    var excludedCapabilities: Provider.Capabilities = [.transfers, .payments, .createBeneficiaries]

    override init() {
        super.init()

        listFormatter.style = .short
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func string(for obj: Any?) -> String? {
        guard let provider = obj as? Provider else {
            return nil
        }
        return string(for: provider)
    }

    func string(for provider: Provider) -> String {
        return string(for: provider.capabilities)
    }

    func string(for capabilities: Provider.Capabilities) -> String {
        let filteredCapabilities = capabilities.subtracting(excludedCapabilities)
        let names = filteredCapabilities.localizedDescriptions

        switch formattingContext {
        case .beginningOfSentence:
            if names.isEmpty { return "" }
            var lowercasedNames = names.map { $0.lowercased(with: .current) }

            var firstName = lowercasedNames.first ?? ""
            firstName = firstName.prefix(1).capitalized(with: .current) + firstName.dropFirst()
            lowercasedNames[0] = firstName

            return listFormatter.string(for: lowercasedNames)
        case .middleOfSentence:
            let lowercasedNames = names.map { $0.lowercased(with: .current) }
            return listFormatter.string(for: lowercasedNames)
        default:
            return listFormatter.string(for: names)
        }
    }
}
