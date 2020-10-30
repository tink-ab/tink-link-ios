import UIKit

extension UINavigationController {
    func setupNavigationBarAppearance() {
        navigationBar.tintColor = Color.navigationBarButton

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.buttonAppearance.normal.titleTextAttributes = [
                .font: Font.body
            ]
            appearance.buttonAppearance.highlighted.titleTextAttributes = [
                .font: Font.body
            ]

            appearance.shadowColor = Color.separator
            appearance.backgroundColor = Color.navigationBarBackground

            let chevronLayer = ChevronLayer()
            let backIndicatorImage = UIImage.image(from: chevronLayer)
            appearance.setBackIndicatorImage(backIndicatorImage, transitionMaskImage: backIndicatorImage)

            appearance.titleTextAttributes = [
                .font: Font.headline,
                .foregroundColor: Color.navigationBarLabel
            ]

            navigationBar.standardAppearance = appearance

            navigationBar.overrideUserInterfaceStyle = Color.navigationBarBackground.resolvedColor(with: traitCollection).isLight ? .light : .dark
        } else {
            // Bar Button Item
            let barButtonItemAppearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [Self.self])
            barButtonItemAppearance.setTitleTextAttributes([
                .font: Font.body
            ], for: .normal)
            barButtonItemAppearance.setTitleTextAttributes([
                .font: Font.body
            ], for: .highlighted)

            // Navigation Bar
            let navigationBarAppearance = UINavigationBar.appearance(whenContainedInInstancesOf: [Self.self])

            let chevronLayer = ChevronLayer()
            let backIndicatorImage = UIImage.image(from: chevronLayer)
            navigationBarAppearance.backIndicatorImage = backIndicatorImage
            navigationBarAppearance.backIndicatorTransitionMaskImage = backIndicatorImage

            navigationBarAppearance.titleTextAttributes = [
                .font: Font.headline,
                .foregroundColor: Color.navigationBarLabel
            ]

            navigationBar.isTranslucent = false
            navigationBar.barTintColor = Color.navigationBarBackground

            navigationBar.barStyle = Color.navigationBarBackground.isLight ? .default : .black
        }
    }
}
