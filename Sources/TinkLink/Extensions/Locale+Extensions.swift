import Foundation

// MARK: - Locales

extension Tink {
    /// Available locales for TinkLink
    public static var availableLocales: [Locale] {
        let locales = [
            Locale(identifier: "da_DK"),
            Locale(identifier: "de_DE"),
            Locale(identifier: "en_GB"),
            Locale(identifier: "en_US"),
            Locale(identifier: "fr_FR"),
            Locale(identifier: "nl_NL"),
            Locale(identifier: "no_NO"),
            Locale(identifier: "sv_SE"),
            Locale(identifier: "pt_PT")
        ]
        return locales
    }

    static func availableLocaleWith(languageCode: String) -> Locale? {
        availableLocales.first { $0.languageCode == languageCode }
    }

    static func availableLocaleWith(regionCode: String) -> Locale? {
        availableLocales.first { $0.regionCode == regionCode }
    }

    /// Fallback locales if no other locale is available
    static var fallbackLocale: Locale {
        Locale(identifier: "en_US")
    }

    /// Default available locale that will be used based on the current locale
    public static var defaultLocale: Locale {
        if let languageCode = Locale.current.languageCode, let locale = availableLocaleWith(languageCode: languageCode) {
            return locale
        } else if let regionCode = Locale.current.regionCode, let locale = availableLocaleWith(regionCode: regionCode) {
            return locale
        } else {
            return fallbackLocale
        }
    }
}
