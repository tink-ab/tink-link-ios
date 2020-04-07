import Foundation

final class CertificatePinningDelegate: NSObject {
    let certificates: [Data]

    init(certificates: [Data]) {
        precondition(!certificates.isEmpty, "Can't do certificate pinning with no certificates.")
        self.certificates = certificates
    }
}

extension CertificatePinningDelegate: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        do {
            let isServerTrusted = try serverTrust.evaluate()

            guard isServerTrusted, serverTrust.certificateCount > 0, let serverCertificate = serverTrust.certificate(at: 0) else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }

            let serverCertificateData = serverCertificate.copyData()

            if certificates.contains(serverCertificateData) {
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
            } else {
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        } catch {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
