import Foundation

extension URLComponents {
    var fragmentParameters: [String: String] {
        guard let fragment = fragment else { return [:] }

        var parameters = [String: String]()

        for keyValuePair in fragment.split(separator: "&") {
            guard let indexOfEqualCharacter = keyValuePair.firstIndex(of: "="),
                indexOfEqualCharacter < keyValuePair.endIndex
                else { continue }

            let key = String(keyValuePair[..<indexOfEqualCharacter])
            let valueStartIndex = keyValuePair.index(after: indexOfEqualCharacter)
            let value = String(keyValuePair[valueStartIndex...])
            parameters[key] = value
        }

        return parameters
    }
}
