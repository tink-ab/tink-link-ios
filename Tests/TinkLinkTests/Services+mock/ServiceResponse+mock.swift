@testable import TinkLink

struct MockedProvider {
    static let nordeaBankID = Provider(
        id: "nordea-bankid",
        displayName: "Nordea",
        kind: .bank,
        status: .enabled,
        credentialKind: .mobileBankID,
        helpText: "",
        isPopular: true,
        fields: [],
        groupDisplayName: "Nordea",
        image: nil,
        displayDescription: "Mobile BankID",
        capabilities: .init(rawValue: 1266),
        accessType: .other,
        marketCode: "SE",
        financialInstitution: .init(id: "dde2463acf40501389de4fca5a3693a4", name: "Nordea")
    )

    static let nordeaPassword = Provider(
        id: "nordea-password",
        displayName: "Nordea",
        kind: .bank,
        status: .enabled,
        credentialKind: .password,
        helpText: "",
        isPopular: true,
        fields: [],
        groupDisplayName: "Nordea",
        image: nil,
        displayDescription: "Password",
        capabilities: .init(rawValue: 1266),
        accessType: .other,
        marketCode: "SE",
        financialInstitution: .init(id: "dde2463acf40501389de4fca5a3693a4", name: "Nordea")
    )

    static let nordeaOpenBanking = Provider(
        id: "se-nordea-ob",
        displayName: "Nordea Open Banking",
        kind: .bank,
        status: .enabled,
        credentialKind: .mobileBankID,
        helpText: "",
        isPopular: true,
        fields: [],
        groupDisplayName: "Nordea",
        image: nil,
        displayDescription: "Mobile BankID",
        capabilities: .init(rawValue: 1266),
        accessType: .openBanking,
        marketCode: "SE",
        financialInstitution: .init(id: "dde2463acf40501389de4fca5a3693a4", name: "Nordea")
    )

    static let sparbankernaBankID = Provider(
        id: "savingsbank-bankid",
        displayName: "Sparbankerna",
        kind: .bank,
        status: .enabled,
        credentialKind: .mobileBankID,
        helpText: "",
        isPopular: true,
        fields: [],
        groupDisplayName: "Swedbank och Sparbankerna",
        image: nil,
        displayDescription: "Mobile BankID",
        capabilities: .init(rawValue: 1534),
        accessType: .other,
        marketCode: "SE",
        financialInstitution: .init(id: "a0afa9bbc85c52aba1b1b8d6a04bc57c", name: "Sparbankerna")
    )

    static let sparbankernaPassword = Provider(
        id: "savingsbank-token",
        displayName: "Sparbankerna",
        kind: .bank,
        status: .enabled,
        credentialKind: .password,
        helpText: "",
        isPopular: true,
        fields: [],
        groupDisplayName: "Swedbank och Sparbankerna",
        image: nil,
        displayDescription: "Security token",
        capabilities: .init(rawValue: 1534),
        accessType: .other,
        marketCode: "SE",
        financialInstitution: .init(id: "a0afa9bbc85c52aba1b1b8d6a04bc57c", name: "Sparbankerna")
    )

    static let swedbankBankID = Provider(
        id: "swedbank-bankid",
        displayName: "Swedbank",
        kind: .bank,
        status: .enabled,
        credentialKind: .mobileBankID,
        helpText: "",
        isPopular: true,
        fields: [],
        groupDisplayName: "Swedbank och Sparbankerna",
        image: nil,
        displayDescription: "Mobile BankID",
        capabilities: .init(rawValue: 1534),
        accessType: .other,
        marketCode: "SE",
        financialInstitution: .init(id: "6c1749b4475e5677a83e9fa4bb60a18a", name: "Swedbank")
    )

    static let swedbankPassword = Provider(
        id: "swedbank-token",
        displayName: "Swedbank",
        kind: .bank,
        status: .enabled,
        credentialKind: .password,
        helpText: "",
        isPopular: true,
        fields: [],
        groupDisplayName: "Swedbank och Sparbankerna",
        image: nil,
        displayDescription: "Security token",
        capabilities: .init(rawValue: 1534),
        accessType: .other,
        marketCode: "SE",
        financialInstitution: .init(id: "6c1749b4475e5677a83e9fa4bb60a18a", name: "Swedbank")
    )
}

struct MockedServiceError {
    static let invalidArgumentError = ServiceError.invalidArgument("Invalid Argument")
    static let unauthenticatedError = ServiceError.unauthenticated("Unauthenticated User")
}
