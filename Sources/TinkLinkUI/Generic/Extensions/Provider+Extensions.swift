import TinkLink

extension Provider {
    var isBeta: Bool {
        releaseStatus == .beta
    }

    var isDemo: Bool {
        kind == .test
    }
}
