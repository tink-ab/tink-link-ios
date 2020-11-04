private var configurations: [Tink.Configuration] = []

extension Tink {
    static var registeredConfigurations: [Tink.Configuration] {
        get { configurations }
        set { configurations = newValue }
    }
}
