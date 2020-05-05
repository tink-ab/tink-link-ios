import Foundation
import TinkLink

final class ProviderCapabilityFormatter: Formatter {
    var formattingContext: Formatter.Context = .unknown

    let listFormatter = HumanEnumeratedFormatter()

    var excludedCapabilities: Provider.Capabilities = [.transfers, .payments, .mortgageAggregation]

    override init() {
        super.init()

        listFormatter.style = .short
    }

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
            let lowercasedNames = names.dropFirst().map({ $0.lowercased(with: .current) })
            var sentenceCasedFirstName: String {
                let firstName = names[0]
                let words = firstName.split(separator: " ")
                if words.isEmpty { return "" }
                let lowercasedWords = words.dropFirst().map({ $0.lowercased(with: .current) })
                return ([String(words[0])] + lowercasedWords)
                    .filter({ !$0.isEmpty })
                    .joined(separator: " ")
            }
            return listFormatter.string(for: [sentenceCasedFirstName] + lowercasedNames)
        case .middleOfSentence:
            let lowercasedNames = names.map({ $0.lowercased(with: .current) })
            return listFormatter.string(for: lowercasedNames)
        default:
            return listFormatter.string(for: names)
        }
    }
}
