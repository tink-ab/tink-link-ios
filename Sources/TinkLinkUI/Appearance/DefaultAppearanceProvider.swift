import UIKit

struct DefaultAppearanceProvider: ColorProviding, FontProviding {
    let background: UIColor = UIColor(red: 253.0 / 255.0, green: 253.0 / 255.0, blue: 253.0 / 255.0, alpha: 1.0)
    let secondaryBackground: UIColor = UIColor(red: 251.0 / 255.0, green: 251.0 / 255.0, blue: 252.0 / 255.0, alpha: 1.0)
    let groupedBackground: UIColor = UIColor(red: 253.0 / 255.0, green: 253.0 / 255.0, blue: 253.0 / 255.0, alpha: 1.0)
    let secondaryGroupedBackground: UIColor = UIColor(red: 251.0 / 255.0, green: 251.0 / 255.0, blue: 252.0 / 255.0, alpha: 1.0)
    let label: UIColor = UIColor(red: 0.149, green: 0.149, blue: 0.149, alpha: 1.0)
    let secondaryLabel: UIColor = UIColor(red: 0.502, green: 0.502, blue: 0.502, alpha: 1.0)
    let separator: UIColor = UIColor(white: 0.87, alpha: 1.0)
    let accent: UIColor = UIColor(red: 0.259, green: 0.467, blue: 0.514, alpha: 1.0)

    let expenses: UIColor = UIColor(red: 0.055, green: 0.620, blue: 0.761, alpha: 1.0)
    let income: UIColor = UIColor(red: 0.212, green: 0.706, blue: 0.447, alpha: 1.0)
    let transfers: UIColor = UIColor(red: 0.282, green: 0.282, blue: 0.282, alpha: 1.0)
    let uncategorized: UIColor = UIColor(red: 0.996, green: 0.682, blue: 0.133, alpha: 1.0)
    let warning: UIColor = UIColor(red: 0.996, green: 0.682, blue: 0.133, alpha: 1.0)
    let critical: UIColor = UIColor(red: 235.0 / 255.0, green: 84.0 / 255.0, blue: 75.0 / 255.0, alpha: 1.0)

    func font(for weight: Font.Weight) -> Font {
        return .systemDefault
    }
}
