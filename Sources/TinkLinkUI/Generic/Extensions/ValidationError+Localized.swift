import Foundation
import TinkLink

extension Form.Field.ValidationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalid(_, let reason):
            return reason
        case .maxLengthLimit(_, let maxLength):
            return String(format: Strings.Field.ValidationError.maxLengthLimit, maxLength)
        case .minLengthLimit(_, let minLength):
            return String(format: Strings.Field.ValidationError.minLengthLimit, minLength)
        case .requiredFieldEmptyValue:
            return Strings.Field.ValidationError.requiredFieldEmptyValue
        }
    }
}
