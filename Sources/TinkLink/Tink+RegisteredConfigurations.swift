import Foundation

private var configurations: [UUID: TinkCore.Configuration] = [:]

extension Tink {
    static func registerConfiguration(_ configuration: TinkCore.Configuration) -> UUID {
        let uuid = UUID()
        configurations[uuid] = configuration
        return uuid
    }

    static func deregisterConfiguration(for uuid: UUID) {
        configurations[uuid] = nil
    }

    static func registeredConfigurations(for url: URL) -> [TinkCore.Configuration] {
        configurations.values.filter { tink in
            guard let appURI = tink.appURI else { return false }
            return url.absoluteString.starts(with: appURI.absoluteString)
        }
    }
}
