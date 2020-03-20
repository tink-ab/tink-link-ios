@testable import TinkLink

extension ServiceError {
    static let invalidArgumentError = ServiceError.invalidArgument("Invalid Argument")
    static let unauthenticatedError = ServiceError.unauthenticated("Unauthenticated User")
}
