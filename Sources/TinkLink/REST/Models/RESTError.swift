import Foundation

struct RESTError: Error, LocalizedError, Decodable {
    let errorMessage: String?
    let errorCode: String

    var statusCodeError: HTTPStatusCodeError? {
        Int(errorCode).flatMap { HTTPStatusCodeError(statusCode: $0) }
    }

    var errorDescription: String? {
        return errorMessage
    }
}

extension RESTError {
    init?(statusCode: Int) {
        if 200..<300 ~= statusCode {
            return nil
        } else {
            self = .init(errorMessage: nil, errorCode: String(statusCode))
        }
    }
}
