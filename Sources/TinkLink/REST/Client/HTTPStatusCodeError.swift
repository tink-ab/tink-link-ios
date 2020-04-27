import Foundation

enum HTTPStatusCodeError: Error {
    /// Status code: 400
    case badRequest

    /// Status code: 401
    case unauthorized

    /// Status code: 403
    case forbidden

    /// Status code: 404
    case notFound

    /// Status code: 500
    case internalServerError

    /// Other 5xx status code errors
    case serverError(Int)

    /// Other 4xx status code errors
    case clientError(Int)

    init?(statusCode: Int) {
        switch statusCode {
        case 400: self = .badRequest
        case 401: self = .unauthorized
        case 403: self = .forbidden
        case 404: self = .notFound
        case 500: self = .internalServerError
        case 400..<500: self = .clientError(statusCode)
        case 500..<600: self = .serverError(statusCode)
        default: return nil
        }
    }
}
