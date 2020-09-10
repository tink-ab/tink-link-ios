import Foundation
import TinkLink

extension Form.Field.ValidationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalid(_, let reason):
            return reason
        case .maxLengthLimit(let fieldName, let maxLength):
            return String(format: Strings.Field.ValidationError.maxLengthLimit, fieldName, maxLength)
        case .minLengthLimit:
            return nil
        case .requiredFieldEmptyValue(let fieldName):
            return String(format: Strings.Field.ValidationError.requiredFieldEmptyValue, fieldName)
        }
    }
}
