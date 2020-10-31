/// Represents an authentication that needs to be completed by the user.
///
/// - Note: Each case have an associated task which need to be completed by the user to continue the process.
public enum AuthenticationTask {
    /// Indicates that there is additional information required from the user to proceed.
    ///
    /// This can for example be an OTP sent via SMS or authetication app.
    case awaitingSupplementalInformation(SupplementInformationTask)
    /// Indicates that there is an authentication in a third party app necessary to proceed with the authentication.
    case awaitingThirdPartyAppAuthentication(ThirdPartyAppAuthenticationTask)
}

public typealias AuthenticationTaskHandler = (_ task: AuthenticationTask) -> Void
