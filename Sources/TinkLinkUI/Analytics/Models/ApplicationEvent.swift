enum ApplicationEvent: String, Encodable {
    case initializedWithoutProvider = "INITIALIZED_WITHOUT_PROVIDER"
    case initializedWithProvider = "INITIALIZED_WITH_PROVIDER"
    case credentialsSubmitted = "CREDENTIALS_SUBMITTED"
    case providerAuthenticationInitialized = "PROVIDER_AUTHENTICATION_INITIALIZED"
    case credentialsValidationFailed = "CREDENTIALS_VALIDATION_FAILED"
    case authenticationSuccessful = "AUTHENTICATION_SUCCESSFUL"
}
