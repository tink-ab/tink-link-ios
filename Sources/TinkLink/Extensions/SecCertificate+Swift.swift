import Foundation

extension SecCertificate {
    func copyData() -> Data {
        return SecCertificateCopyData(self) as Data
    }
}
