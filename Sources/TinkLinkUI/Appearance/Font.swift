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

        fileprivate var textStyle: UIFont.TextStyle {
            switch self {
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
            }
        }
        
        var pointSize: CGFloat {
            return CGFloat(rawValue)
        }
        
        var lineHeight: CGFloat {
            switch self {
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
    
    static func lineSpacing(weight: Weight, size: Size) -> CGFloat {
        let maxLineHeight = size.lineHeight * 1.5
        let scaledLineHeight = UIFontMetrics(forTextStyle: size.textStyle).scaledValue(for: size.lineHeight)
        return min(maxLineHeight, scaledLineHeight) - scaledFont(weight: weight, size: size).lineHeight
    }
    
    private static func font(weight: Weight, size: Size) -> UIFont {
        switch Appearance.fontProvider.font(for: weight) {
        case .custom(let fontName):
            return UIFont(name: fontName, size: size.pointSize)!
        case .systemDefault:
            return UIFont.systemFont(ofSize: size.pointSize, weight: weight.fontWeight)
        }
    }
    
    private static func scaledFont(weight: Weight, size: Size) -> UIFont {
        let lotaGrotesque = font(weight: weight, size: size)
        return UIFontMetrics(forTextStyle: size.textStyle).scaledFont(for: lotaGrotesque, maximumPointSize: size.pointSize * 1.5)
    }
}

// MARK: - Semantic Text Styles

extension Font {
    /// Bold 21 (Mega)
    static var title: UIFont { bold(.mega) }
    /// Bold 15 (Deci)
    static var headline: UIFont { bold(.deci) }
    /// Regular 15 (Deci)
    static var body: UIFont { regular(.deci) }
    /// Bold 15 (Deci)
    static var callout: UIFont { bold(.deci) }
    /// Regular 13 (Micro)
    static var footnote: UIFont { regular(.micro) }
}
