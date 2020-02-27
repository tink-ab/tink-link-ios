import UIKit

extension UIColor {
    convenience init(hex string: String, alpha: CGFloat = 1.0) {
        var hex = string.hasPrefix("#") ? String(string.dropFirst()) : string

        guard hex.count == 3 || hex.count == 6 else {
            self.init(white: 1.0, alpha: 0.0)
            return
        }

        if hex.count == 3 {
            for (index, char) in hex.enumerated() {
                hex.insert(char, at: hex.index(hex.startIndex, offsetBy: index * 2))
            }
        }

        self.init(
            red: CGFloat((Int(hex, radix: 16)! >> 16) & 0xFF) / 255.0,
            green: CGFloat((Int(hex, radix: 16)! >> 8) & 0xFF) / 255.0,
            blue: CGFloat((Int(hex, radix: 16)! >> 0) & 0xFF) / 255.0,
            alpha: alpha
        )
    }

    /// Colorblends the current color with input color
    /// with the screen function:
    /// https://en.wikipedia.org/wiki/Blend_modes#Screen
    ///
    /// - Parameter color: the screen color
    /// - Returns: returns the screened color if successful or self if not
    func screen(with color: UIColor) -> UIColor {
        if let c1 = rgbaComponents(), let c2 = color.rgbaComponents() {
            return UIColor(
                red: 1 - (1 - c1.red) * (1 - c2.red),
                green: 1 - (1 - c1.green) * (1 - c2.green),
                blue: 1 - (1 - c1.blue) * (1 - c2.blue),
                alpha: 1 - (1 - c1.alpha) * (1 - c2.alpha))
        }

        return self
    }

    /// Gets the rgba components of a color if the color
    /// is in a compatible colorspace. If convertion is
    /// successful the returned array has always a
    /// capacity of 4.
    ///
    /// - Returns: Array with rgba components or nil
    private func rgbaComponents() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return (r, g, b, a)
        }

        return nil
    }

    func mixedWith(color: UIColor, factor: CGFloat) -> UIColor {
        if let c1 = rgbaComponents(), let c2 = color.rgbaComponents() {
            return UIColor(
                red: c1.red * (1.0 - factor) + c2.red * factor,
                green: c1.green * (1.0 - factor) + c2.green * factor,
                blue: c1.blue * (1.0 - factor) + c2.blue * factor,
                alpha: c1.alpha * (1.0 - factor) + c2.alpha * factor
            )
        } else {
            return self
        }
    }

    private func adjust(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: r + red, green: g + green, blue: b + blue, alpha: a + alpha)
    }

    func adjust(_ adjustment: CGFloat) -> UIColor {
        return adjust(red: adjustment, green: adjustment, blue: adjustment, alpha: 0)
    }
}

