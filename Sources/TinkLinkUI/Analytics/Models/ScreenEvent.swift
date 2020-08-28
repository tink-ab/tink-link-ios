enum ScreenEvent: String {
    case error
    case success = "success_screen"
    case supplementalInformation = "supplemental_information_screen"
    case providerSelection = "provider_selection_screen"
    case authenticationUserTypeSelection = "authentication_user_type_selection_screen"
    case financialInstitutionSelection = "financial_institution_selection_screen"
    case accessTypeSelection = "access_type_selection_screen"
    case credentialsTypeSelection = "credentials_type_selection_screen"
    case submitCredentials = "submit_credentials_screen"
}
