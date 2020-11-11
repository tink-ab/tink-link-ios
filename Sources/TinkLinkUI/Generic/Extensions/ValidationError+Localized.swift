import Foundation
import TinkLink

extension Form.Field.ValidationError: LocalizedError {
    public var errorDescription: String? {
        switch code {
        case .invalid:
            return reason
        case .maxLengthLimit:
            return String(format: Strings.Field.ValidationError.maxLengthLimit, maxLength ?? 0)
        case .minLengthLimit:
            return String(format: Strings.Field.ValidationError.minLengthLimit, minLength ?? 0)
        case .requiredFieldEmptyValue:
            return Strings.Field.ValidationError.requiredFieldEmptyValue
        default:
            return nil
        }
    }
}
