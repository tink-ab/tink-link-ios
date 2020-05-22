import CoreGraphics

extension CGImage {
    var withMaskedWhiteChannel: CGImage? {
        let maxColorValue: CGFloat

        if bitmapInfo == .floatComponents {
            maxColorValue = 1.0
        } else {
            maxColorValue = CGFloat(pow(2.0, Double(bitsPerComponent)) - 1.0)
        }

        return copy(maskingColorComponents: Array(repeating: maxColorValue, count: (colorSpace?.numberOfComponents ?? 1) * 2))
    }
}
