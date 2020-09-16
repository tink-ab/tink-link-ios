import TinkCore

extension Provider {
    static let nordeaBankID = Provider(
        id: "nordea-bankid",
        displayName: "Nordea",
        authenticationUserType: .personal,
        kind: .bank,
        status: .enabled,
        credentialsKind: .mobileBankID,
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
        authenticationUserType: .personal,
        kind: .bank,
        status: .enabled,
        credentialsKind: .password,
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
        authenticationUserType: .personal,
        kind: .bank,
        status: .enabled,
        credentialsKind: .mobileBankID,
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
        authenticationUserType: .personal,
        kind: .bank,
        status: .enabled,
        credentialsKind: .mobileBankID,
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
        authenticationUserType: .personal,
        kind: .bank,
        status: .enabled,
        credentialsKind: .password,
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
        authenticationUserType: .personal,
        kind: .bank,
        status: .enabled,
        credentialsKind: .mobileBankID,
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
        authenticationUserType: .personal,
        kind: .bank,
        status: .enabled,
        credentialsKind: .password,
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

    static let testSupplementalInformation = Provider(
        id: "se-test-multi-supplemental",
        displayName: "Test Multi-Supplemental",
        authenticationUserType: .personal,
        kind: .test,
        status: .enabled,
        credentialsKind: .password,
        helpText: "Use the same username and password as you would in the bank\'s mobile app.",
        isPopular: true,
        fields: [FieldSpecification(fieldDescription: "Username", hint: "", maxLength: nil, minLength: nil, isMasked: false, isNumeric: false, isImmutable: false, isOptional: false, name: "username", initialValue: "", pattern: "", patternError: "", helpText: "")],
        groupDisplayName: "Test Multi-Supplemental",
        image: nil,
        displayDescription: "Password",
        capabilities: .init(rawValue: 1276),
        accessType: .other,
        marketCode: "SE",
        financialInstitution: .init(id: "3590cce61e1256dd9cb2c32bfacb713b", name: "Test Multi-Supplemental")
    )

    static let testThirdPartyAuthentication = Provider(
        id: "se-test-multi-third-party",
        displayName: "Test Third Party Authentication",
        authenticationUserType: .personal,
        kind: .test,
        status: .enabled,
        credentialsKind: .thirdPartyAuthentication,
        helpText: "Use the same username and password as you would in the bank\'s mobile app.",
        isPopular: true,
        fields: [],
        groupDisplayName: "Test Third Party Authentication",
        image: nil,
        displayDescription: "Test",
        capabilities: .init(rawValue: 1276),
        accessType: .other,
        marketCode: "SE",
        financialInstitution: .init(id: "3590cce61e1256dd9cb2c32bfacb713b", name: "Test Multi-Supplemental")
    )
}
