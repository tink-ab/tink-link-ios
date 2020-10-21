import TinkLink

extension Provider.AccessType {
    var description: String {
        switch self {
        case .openBanking:
            return "Open Banking"
        case .other, .unknown:
            return Strings.SelectAccessType.otherType
        }
    }
}
