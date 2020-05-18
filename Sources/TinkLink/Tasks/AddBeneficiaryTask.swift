public final class AddBeneficiaryTask: Cancellable {
    public enum Authentication {
        case awaitingSupplementalInformation(SupplementInformationTask)
        case awaitingThirdPartyAppAuthentication(ThirdPartyAppAuthenticationTask)
    }

    public func cancel() {

    }
}
