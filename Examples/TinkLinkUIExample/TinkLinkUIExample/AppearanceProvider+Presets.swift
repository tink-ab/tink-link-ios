import UIKit
import TinkLinkUI

extension AppearanceProvider {

    private static func makeProvider(folderName: String) -> AppearanceProvider {
        return AppearanceProvider(
            background: UIColor(named: "\(folderName)/Background")!,
            secondaryBackground: UIColor(named: "\(folderName)/SecondaryBackground")!,
            groupedBackground: UIColor(named: "\(folderName)/GroupedBackground")!,
            secondaryGroupedBackground: UIColor(named: "\(folderName)/GroupedSecondaryBackground")!,
            label: UIColor(named: "\(folderName)/Label")!,
            secondaryLabel: UIColor(named: "\(folderName)/SecondaryLabel")!,
            separator: UIColor(named: "\(folderName)/Separator")!,
            accent: UIColor(named: "\(folderName)/Accent")!,
            expenses: UIColor(named: "\(folderName)/Expenses")!,
            income: UIColor(named: "\(folderName)/Income")!,
            transfers: UIColor(named: "\(folderName)/Transfers")!,
            uncategorized: UIColor(named: "\(folderName)/Uncategorized")!,
            warning: UIColor(named: "\(folderName)/Uncategorized")!)
            
    }
    
    private static func makeProviderWithFonts(folderName: String, light: String, regular: String, semiBold: String, bold: String) -> AppearanceProvider {
        return AppearanceProvider(
            background: UIColor(named: "\(folderName)/Background")!,
            secondaryBackground: UIColor(named: "\(folderName)/SecondaryBackground")!,
            groupedBackground: UIColor(named: "\(folderName)/GroupedBackground")!,
            secondaryGroupedBackground: UIColor(named: "\(folderName)/GroupedSecondaryBackground")!,
            label: UIColor(named: "\(folderName)/Label")!,
            secondaryLabel: UIColor(named: "\(folderName)/SecondaryLabel")!,
            separator: UIColor(named: "\(folderName)/Separator")!,
            accent: UIColor(named: "\(folderName)/Accent")!,
            expenses: UIColor(named: "\(folderName)/Expenses")!,
            income: UIColor(named: "\(folderName)/Income")!,
            transfers: UIColor(named: "\(folderName)/Transfers")!,
            uncategorized: UIColor(named: "\(folderName)/Uncategorized")!,
            warning: UIColor(named: "\(folderName)/Uncategorized")!,
            lightFont: .custom("\(light)"),
            regularFont: .custom("\(regular)"),
            semiBoldFont: .custom("\(semiBold)"),
            boldFont: .custom("\(bold)"))
            
    }

    static var darkGreen: AppearanceProvider = makeProvider(folderName: "DarkGreen")
    static var blue: AppearanceProvider = makeProvider(folderName: "Blue")
    static var purple: AppearanceProvider = makeProvider(folderName: "Purple")
    static var chewinggum: AppearanceProvider = makeProviderWithFonts(folderName: "Chewinggum", light: "Avenir-Light", regular: "Avenir-Book", semiBold: "Avenir-Medium", bold: "Avenir-Black")
    static var strict: AppearanceProvider = makeProviderWithFonts(folderName: "Strict", light: "GillSans", regular: "GillSans", semiBold: "GillSans", bold: "GillSans-SemiBold")
}
