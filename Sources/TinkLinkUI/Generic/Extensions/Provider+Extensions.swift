import TinkLink

extension Provider {
    var isDemo: Bool {
        kind == .test
    }
}
