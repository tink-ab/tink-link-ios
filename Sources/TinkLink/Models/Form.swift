import Foundation

/// A `Form` is used to determine what a user needs to input in order to proceed. For example it could be a username and a password field.
///
/// Here's how to create a form for a provider with a username and password field and how to update the fields.
///
/// ```swift
/// var form = Form(provider: <#Provider#>)
/// form.fields[name: "username"]?.text = <#String#>
/// form.fields[name: "password"]?.text = <#String#>
/// ...
/// ```
///
/// ### Configuring UITextFields from form fields
///
/// The `Field` within a `Form` contains attributes that map well to `UITextField`.
///
/// ```swift
/// for field in form.fields {
///     let textField = UITextField()
///     textField.placeholder = field.attributes.placeholder
///     textField.isSecureTextEntry = field.attributes.isSecureTextEntry
///     textField.isEnabled = field.attributes.isEditable
///     textField.text = field.text
///     <#Add to view#>
/// }
/// ```
/// ### Form validation
///
/// Validate before you submit a request to add credentials or supplement information.
///
/// Use `areFieldsValid` to check if all form fields are valid. For example, you can use this to enable a submit button when text fields change.
///
/// ```swift
/// @objc func textFieldDidChange(_ notification: Notification) {
///     submitButton.isEnabled = form.areFieldsValid
/// }
/// ```
///
/// Use validateFields() to validate all fields. If not valid, it will throw an error that contains more information about which fields are not valid and why.
///
/// ```swift
/// do {
///     try form.validateFields()
/// } catch let error as Form.Fields.ValidationError {
///     if let usernameFieldError = error[fieldName: "username"] {
///         usernameValidationErrorLabel.text = usernameFieldError.errorDescription
///     }
/// }
/// ```
public struct Form {
    /// A collection of fields.
    ///
    /// Represents a list of fields and provides access to the fields. Each field in can be accessed either by index or by field name.
    public struct Fields: MutableCollection, RandomAccessCollection {
        var fields: [Form.Field]

        // MARK: Collection Conformance

        public var startIndex: Int { fields.startIndex }
        public var endIndex: Int { fields.endIndex }
        public subscript(position: Int) -> Form.Field {
            get { fields[position] }
            set { fields[position] = newValue }
        }

        public func index(after i: Int) -> Int { fields.index(after: i) }

        // MARK: Dictionary Lookup

        /// Accesses the field associated with the given field for reading and writing.
        ///
        /// This name based subscript returns the first field with the same name, or `nil` if the field is not found.
        ///
        /// - Parameter name: The name of the field to find in the list.
        /// - Returns: The field associciated with `name` if it exists; otherwise, `nil`.
        public subscript(name fieldName: String) -> Form.Field? {
            get {
                return fields.first(where: { $0.name == fieldName })
            }
            set {
                if let index = fields.firstIndex(where: { $0.name == fieldName }) {
                    if let field = newValue {
                        fields[index] = field
                    } else {
                        fields.remove(at: index)
                    }
                } else if let field = newValue {
                    fields.append(field)
                }
            }
        }
    }

    /// The fields associated with this form.
    public var fields: Fields

    internal init(fieldSpecifications: [Provider.FieldSpecification]) {
        self.fields = Fields(fields: fieldSpecifications.map { Field(fieldSpecification: $0) })
    }

    /// Returns a Boolean value indicating whether every field in the form are valid.
    ///
    /// - Returns: `true` if all fields in the form have valid text; otherwise, `false`.
    public var areFieldsValid: Bool {
        return fields.areFieldsValid
    }

    /// Validate all fields.
    ///
    /// Use this method to validate all fields in the form or catch the value if one or more field are invalid.
    ///
    /// - Returns: `true` if all fields in the form have valid text; otherwise, `false`.
    /// - Throws: A `Form.ValidationError` if one or more fields are invalid.
    public func validateFields() throws {
        try fields.validateFields()
    }

    internal func makeFields() -> [String: String] {
        var fieldValues: [String: String] = [:]
        for field in fields {
            fieldValues[field.name] = field.text
        }
        return fieldValues
    }

    /// A `Field` represent one specific input (usually a text field) that the user need to enter in order to add a credential.
    public struct Field {
        /// The current text input of the field. Update this to reflect the user's input.
        public var text: String
        /// The name of the field.
        public let name: String
        /// The validation rules that determines whether the `text` property is valid.
        public let validationRules: ValidationRules
        /// The attributes of the field.
        ///
        /// You can use the attributes to set up a text field properly. They contain properties
        /// like input type, placeholder and description.
        public let attributes: Attributes

        internal init(fieldSpecification: Provider.FieldSpecification) {
            self.text = fieldSpecification.initialValue
            self.name = fieldSpecification.name
            self.validationRules = ValidationRules(
                isOptional: fieldSpecification.isOptional,
                maxLength: fieldSpecification.maxLength,
                minLength: fieldSpecification.minLength,
                regex: fieldSpecification.pattern,
                regexError: fieldSpecification.patternError
            )
            self.attributes = Attributes(
                description: fieldSpecification.fieldDescription,
                placeholder: fieldSpecification.hint,
                helpText: fieldSpecification.helpText,
                isSecureTextEntry: fieldSpecification.isMasked,
                inputType: fieldSpecification.isNumeric ? .numeric : .default,
                isEditable: !fieldSpecification.isImmutable || fieldSpecification.initialValue.isEmpty
            )
        }

        /// Validation rules for a field.
        ///
        /// Represents the rules for validating a form field.
        public struct ValidationRules {
            /// If `true` the field is not required to have text for the field to be valid.
            public let isOptional: Bool

            /// Maximum length of value.
            ///
            /// Use this to e.g. limit user input to only accept input until `maxLength` is reached.
            public let maxLength: Int?

            /// Minimum length of value.
            public let minLength: Int?

            internal let regex: String
            internal let regexError: String

            internal func validate(_ value: String, fieldName name: String) throws {
                if value.isEmpty, !isOptional {
                    throw ValidationError.requiredFieldEmptyValue(fieldName: name)
                } else if let maxLength = maxLength, maxLength > 0 && maxLength < value.count {
                    throw ValidationError.maxLengthLimit(fieldName: name, maxLength: maxLength)
                } else if let minLength = minLength, minLength > 0 && minLength > value.count {
                    throw ValidationError.minLengthLimit(fieldName: name, minLength: minLength)
                } else if !regex.isEmpty, let regex = try? NSRegularExpression(pattern: regex, options: []) {
                    let range = regex.rangeOfFirstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count))
                    if range.location == NSNotFound {
                        throw ValidationError.invalid(fieldName: name, reason: regexError)
                    }
                }
            }
        }

        /// Attributes to apply to a UI element that will represent a field.
        public struct Attributes {
            public enum InputType {
                /// An input type suitable for normal text input.
                case `default`
                /// An input type suitable for e.g. PIN entry.
                case numeric
            }

            /// A string to display next to the field to explain what the field is for.
            public let description: String

            /// A string to display when there is no other text in the text field.
            public let placeholder: String

            /// A string to display next to the field with information about what the user should enter in the text field.
            public let helpText: String

            /// Identifies whether the text object should hide the text being entered.
            public let isSecureTextEntry: Bool

            /// The input type associated with the field.
            public let inputType: InputType

            /// A Boolean value indicating whether the field can be edited.
            public let isEditable: Bool
        }

        /// Describes a field validation error.
        public enum ValidationError: Error, LocalizedError {
            /// Field's `text` was invalid. See `reason` for explanation why.
            case invalid(fieldName: String, reason: String)

            /// Field's `text` was too long.
            case maxLengthLimit(fieldName: String, maxLength: Int)

            /// Field's `text` was too short.
            case minLengthLimit(fieldName: String, minLength: Int)

            /// Missing `text` for required field.
            case requiredFieldEmptyValue(fieldName: String)

            var fieldName: String {
                switch self {
                case .invalid(let fieldName, _):
                    return fieldName
                case .maxLengthLimit(let fieldName, _):
                    return fieldName
                case .minLengthLimit(let fieldName, _):
                    return fieldName
                case .requiredFieldEmptyValue(let fieldName):
                    return fieldName
                }
            }

            /// An error message describing what is the reason for the validation failure.
            public var errorDescription: String? {
                switch self {
                case .invalid(_, let reason):
                    return reason
                case .maxLengthLimit(_, let maxLength):
                    return "Field can't be longer than \(maxLength)"
                case .minLengthLimit(_, let minLength):
                    return "Field can't be shorter than \(minLength)"
                case .requiredFieldEmptyValue:
                    return "Required field"
                }
            }
        }

        /// Returns a Boolean value indicating whether the field is valid.
        ///
        /// To check why `text` wasn't valid if `false`, call `validate()` and check the thrown error for validation failure reason.
        ///
        /// - Returns: `true` if the field pass the validation rules; otherwise, `false`.
        public var isValid: Bool {
            do {
                try validate()
                return true
            } catch {
                return false
            }
        }

        /// Validate field.
        ///
        /// Use this method to validate the current `text` value of the field or to catch the value if invalid.
        ///
        /// - Throws: A `Form.Field.ValidationError` if the field's `text` is invalid.
        public func validate() throws {
            let value = text
            try validationRules.validate(value, fieldName: name)
        }
    }

    /// Describes a form validation error.
    public struct ValidationError: Error {
        /// Describes one or more field validation errors.
        public var errors: [Form.Field.ValidationError]

        /// Accesses the validation error associated with the given field.
        ///
        /// This name based subscript returns the first error with the same name, or `nil` if an error is not found.
        ///
        /// - Parameter fieldName: The name of the field to find an error for.
        /// - Returns: The validation error associciated with `fieldName` if it exists; otherwise, `nil`.
        public subscript(fieldName fieldName: String) -> Form.Field.ValidationError? {
            errors.first(where: { $0.fieldName == fieldName })
        }
    }
}

extension Form {
    /// Creates a form for the given provider.
    ///
    /// This creates a form to use for creating a credentials for a specific provider.
    ///
    /// - Parameter provider: The provider to create a form for.
    public init(provider: Provider) {
        self.init(fieldSpecifications: provider.fields)
    }

    /// Creates a form for the given credentials.
    ///
    /// This creates a form to use for supplementing information for a credentials.
    ///
    /// - Parameter credential: The credentials to create a form for.
    public init(credentials: Credentials) {
        self.init(fieldSpecifications: credentials.supplementalInformationFields)
    }
}

extension Form.Fields {
    /// Validate fields.
    ///
    /// Use this method to validate all fields. If any field is not valid, it will throw an error that contains
    /// more information about which fields are not valid and why.
    ///
    /// ```swift
    /// do {
    ///     try form.validateFields()
    /// } catch let error as Form.Fields.ValidationError {
    ///     if let usernameFieldError = error[fieldName: "username"] {
    ///         usernameValidationErrorLabel.text = usernameFieldError.errorDescription
    ///     }
    /// }
    /// ```
    ///
    /// - Throws: A `Form.ValidationError` if any of the fields' `text` value is invalid.
    func validateFields() throws {
        var fieldsValidationError = Form.ValidationError(errors: [])
        for field in fields {
            do {
                try field.validate()
            } catch let error as Form.Field.ValidationError {
                fieldsValidationError.errors.append(error)
            } catch {
                fatalError()
            }
        }
        guard fieldsValidationError.errors.isEmpty else { throw fieldsValidationError }
    }

    /// A Boolean value indicating whether all fields have valid values.
    ///
    /// Use `areFieldsValid` to check if all form fields are valid. For example, you can use this to enable a submit button when text fields change.
    ///
    /// ```swift
    /// @objc func textFieldDidChange(_ notification: Notification) {
    ///     submitButton.isEnabled = form.areFieldsValid
    /// }
    /// ```
    ///
    /// - Returns: `true` if all fields in the form have valid text; otherwise, `false`.
    var areFieldsValid: Bool {
        do {
            try validateFields()
            return true
        } catch {
            return false
        }
    }
}
