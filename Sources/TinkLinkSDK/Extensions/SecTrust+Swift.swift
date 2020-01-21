import Security

extension SecTrust {
    func evaluate() throws -> Bool {
        #if os(iOS)
            if #available(iOS 12.0, *) {
                var error: CFError?
                let isTrusted = SecTrustEvaluateWithError(self, &error)
                if let error = error {
                    throw error
                }
                return isTrusted
            } else {
                var result: SecTrustResultType!
                let status = SecTrustEvaluate(self, &result)
                if status != noErr {
                    switch result {
                    case .unspecified, .proceed: return true
                    default: return false
                    }
                } else if let error = CFErrorCreate(nil, kCFErrorDomainOSStatus, CFIndex(status), nil) {
                    throw error
                } else {
                    return false
                }
            }
        #elseif os(macOS)
            if #available(macOS 10.14, *) {
                var error: CFError?
                let isTrusted = SecTrustEvaluateWithError(self, &error)
                if let error = error {
                    throw error
                }
                return isTrusted
            } else {
                var result: SecTrustResultType!
                let status = SecTrustEvaluate(self, &result)
                if status != noErr {
                    switch result {
                    case .unspecified, .proceed: return true
                    default: return false
                    }
                } else if let error = CFErrorCreate(nil, kCFErrorDomainOSStatus, CFIndex(status), nil) {
                    throw error
                } else {
                    return false
                }
            }
        #endif
    }

    var certificateCount: Int { SecTrustGetCertificateCount(self) }

    func certificate(at index: Int) -> SecCertificate? {
        return SecTrustGetCertificateAtIndex(self, index)
    }
}
