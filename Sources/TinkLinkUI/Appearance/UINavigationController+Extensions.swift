import UIKit

extension UINavigationController {
    func setupNavigationBarAppearance() {
        navigationBar.tintColor = Color.navigationBarButton

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.buttonAppearance.normal.titleTextAttributes = [
                .font: Font.body1
            ]
            appearance.buttonAppearance.highlighted.titleTextAttributes = [
                .font: Font.body1
            ]

            appearance.shadowColor = Color.separator
            appearance.backgroundColor = Color.navigationBarBackground

            appearance.titleTextAttributes = [
                .font: Font.subtitle1,
                .foregroundColor: Color.navigationBarLabel
            ]

            navigationBar.standardAppearance = appearance
        } else {
            // Bar Button Item
            let barButtonItemAppearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [Self.self])
            barButtonItemAppearance.setTitleTextAttributes([
                .font: Font.body1
            ], for: .normal)
            barButtonItemAppearance.setTitleTextAttributes([
                .font: Font.body1
            ], for: .highlighted)

            // Navigation Bar
            let navigationBarAppearance = UINavigationBar.appearance(whenContainedInInstancesOf: [Self.self])

            navigationBarAppearance.titleTextAttributes = [
                .font: Font.subtitle1,
                .foregroundColor: Color.navigationBarLabel
            ]

            navigationBar.isTranslucent = false
            navigationBar.barTintColor = Color.navigationBarBackground

            navigationBar.barStyle = Color.navigationBarBackground.isLight ? .default : .black
        }
    }
}
