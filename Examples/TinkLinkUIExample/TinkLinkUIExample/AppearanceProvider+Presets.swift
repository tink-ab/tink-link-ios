import UIKit
import TinkLinkUI

extension AppearanceProvider {

    private static func makeProvider(folderName: String) -> AppearanceProvider {
        let color = ColorProvider()
        color.background = UIColor(named: "\(folderName)/Background")!
        color.secondaryBackground = UIColor(named: "\(folderName)/SecondaryBackground")!
        color.groupedBackground = UIColor(named: "\(folderName)/GroupedBackground")!
        color.secondaryGroupedBackground = UIColor(named: "\(folderName)/GroupedSecondaryBackground")!
        color.label = UIColor(named: "\(folderName)/Label")!
        color.secondaryLabel = UIColor(named: "\(folderName)/SecondaryLabel")!
        color.separator = UIColor(named: "\(folderName)/Separator")!
        color.accent = UIColor(named: "\(folderName)/Accent")!
        color.warning = UIColor(named: "\(folderName)/Uncategorized")!
        color.critical = .red
        return AppearanceProvider(colors: color)
    }
    
    private static func makeProviderWithFonts(folderName: String, light: String, regular: String, semiBold: String, bold: String) -> AppearanceProvider {
        let color = ColorProvider()
        let font = FontProvider()
        color.background = UIColor(named: "\(folderName)/Background")!
        color.secondaryBackground = UIColor(named: "\(folderName)/SecondaryBackground")!
        color.groupedBackground = UIColor(named: "\(folderName)/GroupedBackground")!
        color.secondaryGroupedBackground = UIColor(named: "\(folderName)/GroupedSecondaryBackground")!
        color.label = UIColor(named: "\(folderName)/Label")!
        color.secondaryLabel = UIColor(named: "\(folderName)/SecondaryLabel")!
        color.separator = UIColor(named: "\(folderName)/Separator")!
        color.accent = UIColor(named: "\(folderName)/Accent")!
        color.warning = UIColor(named: "\(folderName)/Uncategorized")!
        color.critical = .red
        font.lightFont = .custom("\(light)")
        font.regularFont = .custom("\(regular)")
        font.semiBoldFont = .custom("\(semiBold)")
        font.boldFont = .custom("\(bold)")
        return AppearanceProvider(colors: color, fonts: font)
            
    }

    static var darkGreen: AppearanceProvider = makeProvider(folderName: "DarkGreen")
    static var blue: AppearanceProvider = makeProvider(folderName: "Blue")
    static var purple: AppearanceProvider = makeProvider(folderName: "Purple")
    static var chewinggum: AppearanceProvider = makeProviderWithFonts(folderName: "Chewinggum", light: "Avenir-Light", regular: "Avenir-Book", semiBold: "Avenir-Medium", bold: "Avenir-Black")
    static var strict: AppearanceProvider = makeProviderWithFonts(folderName: "Strict", light: "GillSans", regular: "GillSans", semiBold: "GillSans", bold: "GillSans-SemiBold")
}
