import UIKit

/// A type that represents a specific font.
public enum Font {
    /// Uses a custom font with the provided associated value as font name.
    case custom(String)
    /// Uses the default system font.
    case systemDefault
}

extension Font {
    /// A type that determines the weight of a font.
    public enum Weight {
        /// The regular font weight.
        case regular
        /// The bold font weight.
        case bold

        init(weight: UIFont.Weight) {
            switch weight {
            case .regular:
                self = .regular
            case .semibold, .bold:
                self = .bold
            default:
                self = .regular
            }
        }

        var fontWeight: UIFont.Weight {
            switch self {
            case .regular:
                return .regular
            case .bold:
                return .bold
            }
        }
    }
}

extension Font {
    enum Size: UInt {
        /// 35
        case tera = 35

        /// 26
        case giga = 26

        /// 21
        case mega = 21

        /// 17
        case hecto = 17

        /// 15
        case deci = 15

        /// 13
        case micro = 13

        /// 11
        case nano = 11

        /// 10
        case beta = 10

        fileprivate var textStyle: UIFont.TextStyle {
            switch self {
            case .tera:
                return UIFont.TextStyle.title1
            case .giga:
                return UIFont.TextStyle.title2
            case .mega:
                return UIFont.TextStyle.title3
            case .hecto:
                return UIFont.TextStyle.headline
            case .deci:
                return UIFont.TextStyle.subheadline
            case .micro:
                return UIFont.TextStyle.footnote
            case .nano:
                return UIFont.TextStyle.caption2
            case .beta:
                return UIFont.TextStyle.caption2
            }
        }

        var pointSize: CGFloat {
            return CGFloat(rawValue)
        }

        var lineHeight: CGFloat {
            switch self {
            case .tera:
                return 40
            case .giga:
                return 30
            case .mega:
                return 28
            case .hecto:
                return 24
            case .deci:
                return 20
            case .micro:
                return 20
            case .nano:
                return 16
            case .beta:
                return 16
            }
        }
    }

    private static func regular(_ size: Size, adjustsFontForContentSizeCategory: Bool = true) -> UIFont {
        if adjustsFontForContentSizeCategory {
            return scaledFont(weight: .regular, size: size)
        } else {
            return font(weight: .regular, size: size)
        }
    }

    private static func bold(_ size: Size, adjustsFontForContentSizeCategory: Bool = true) -> UIFont {
        if adjustsFontForContentSizeCategory {
            return scaledFont(weight: .bold, size: size)
        } else {
            return font(weight: .bold, size: size)
        }
    }

    static func lineSpacing(weight: UIFont.Weight, size: Size) -> CGFloat {
        let maxLineHeight = size.lineHeight * 1.5
        let scaledLineHeight = UIFontMetrics(forTextStyle: size.textStyle).scaledValue(for: size.lineHeight)
        return min(maxLineHeight, scaledLineHeight) - scaledFont(weight: weight, size: size).lineHeight
    }

    private static func font(weight: UIFont.Weight, size: Size) -> UIFont {
        switch Appearance.fontProvider.font(for: .init(weight: weight)) {
        case .custom(let fontName):
            return UIFont(name: fontName, size: size.pointSize)!
        case .systemDefault:
            return UIFont.systemFont(ofSize: size.pointSize, weight: weight)
        }
    }

    private static func scaledFont(weight: UIFont.Weight, size: Size) -> UIFont {
        let lotaGrotesque = font(weight: weight, size: size)
        return UIFontMetrics(forTextStyle: size.textStyle).scaledFont(for: lotaGrotesque, maximumPointSize: size.pointSize * 1.5)
    }
}

// MARK: - Semantic Text Styles

extension Font {
    /// Bold 35 (Tera)
    static var header4: UIFont { bold(.tera) }
    /// Bold 26 (Giga)
    static var header5: UIFont { bold(.giga) }
    /// Bold 21 (Mega)
    static var header6: UIFont { bold(.mega) }
    /// Bold 15 (Deci)
    static var subtitle1: UIFont { bold(.deci) }
    /// Bold 13 (micro)
    static var subtitle2: UIFont { bold(.micro) }
    /// Regular 15 (Deci)
    static var body1: UIFont { regular(.deci) }
    /// Regular 13 (micro)
    static var body2: UIFont { regular(.micro) }
    /// Bold 15 (Deci)
    static var button: UIFont { bold(.deci) }
    /// Regular 11 (nano)
    static var caption: UIFont { regular(.nano) }
    /// Bold 10
    ///
    /// - Note: Only for use with provider beta tag.
    static var beta: UIFont { bold(.beta) }
}
