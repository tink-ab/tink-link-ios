import Foundation

struct RESTFieldsString: Codable {
    let fields: [RESTField]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringData = try container.decode(String.self).data(using: .utf8) {
            fields = try JSONDecoder().decode([RESTField].self, from: stringData)
        } else {
            fields = []
        }
    }
}
struct RESTField: Codable {

    var defaultValue: String?
    var _description: String?
    /** Text displayed next to the input field */
    var helpText: String?
    /** Gray text in the input view (Similar to a placeholder) */
    var hint: String?
    var immutable: Bool?
    /** Controls whether or not the field should be shown masked, like a password field */
    var masked: Bool?
    var maxLength: Int?
    var minLength: Int?
    var name: String?
    var numeric: Bool?
    var _optional: Bool?
    /** A list of options where the user should select one */
    var options: [String]?
    var pattern: String?
    var patternError: String?
    var value: String?
    var sensitive: Bool?
    /** Display boolean value as checkbox */
    var checkbox: Bool?
    /** A serialized JSON containing additional information that could be useful */
    var additionalInfo: String?

    init(defaultValue: String?, _description: String?, helpText: String?, hint: String?, immutable: Bool?, masked: Bool?, maxLength: Int?, minLength: Int?, name: String?, numeric: Bool?, _optional: Bool?, options: [String]?, pattern: String?, patternError: String?, value: String?, sensitive: Bool?, checkbox: Bool?, additionalInfo: String?) {
        self.defaultValue = defaultValue
        self._description = _description
        self.helpText = helpText
        self.hint = hint
        self.immutable = immutable
        self.masked = masked
        self.maxLength = maxLength
        self.minLength = minLength
        self.name = name
        self.numeric = numeric
        self._optional = _optional
        self.options = options
        self.pattern = pattern
        self.patternError = patternError
        self.value = value
        self.sensitive = sensitive
        self.checkbox = checkbox
        self.additionalInfo = additionalInfo
    }

    enum CodingKeys: String, CodingKey {
        case defaultValue
        case _description = "description"
        case helpText
        case hint
        case immutable
        case masked
        case maxLength
        case minLength
        case name
        case numeric
        case _optional = "optional"
        case options
        case pattern
        case patternError
        case value
        case sensitive
        case checkbox
        case additionalInfo
    }

}

