import Foundation

private var configurations: [UUID: Tink.Configuration] = [:]

extension Tink {
    static func registerConfiguration(_ configuration: Tink.Configuration) -> UUID {
        let uuid = UUID()
        configurations[uuid] = configuration
        return uuid
    }

    static func removeRegisteredConfiguration(for uuid: UUID) {
        configurations[uuid] = nil
    }

    static func registeredConfigurations(for url: URL) -> [Tink.Configuration] {
        configurations.values.filter { url.absoluteString.starts(with: $0.redirectURI.absoluteString) }
    }
}
