import Foundation

class HumanEnumeratedFormatter: Formatter {
    public enum Style {
        case short
        case long

        var localizedLastJoinWord: String {
            switch self {
            case .short:
                return "&"
            case .long:
                return Strings.Generic.and
            }
        }
    }

    public var style: Style = .long

    public override func string(for obj: Any?) -> String? {
        guard let items = obj as? [String] else { return nil }
        return string(for: items)
    }

    public func string(for items: [String]) -> String {
        var output = [String]()
        items.enumerated().forEach({ offset, elem in
            output.append(elem)
            if offset == items.count - 2 {
                output.append(" " + style.localizedLastJoinWord + " ")
            } else if offset < items.count - 2 {
                output.append(", ")
            }
        })

        return output.joined()
    }
}
