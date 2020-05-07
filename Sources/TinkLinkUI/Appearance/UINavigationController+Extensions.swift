import UIKit

extension UINavigationController {
    func setupNavigationBarAppearance() {

        navigationBar.tintColor = Color.accent

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.buttonAppearance.normal.titleTextAttributes = [
                .font: Font.subheadline
            ]
            appearance.buttonAppearance.highlighted.titleTextAttributes = [
                .font: Font.subheadline
            ]

            appearance.shadowColor = Color.separator
            appearance.backgroundColor = Color.background

            let chevronLayer = ChevronLayer()
            let backIndicatorImage = UIImage.image(from: chevronLayer)
            appearance.setBackIndicatorImage(backIndicatorImage, transitionMaskImage: backIndicatorImage)

            appearance.titleTextAttributes = [
                .font: Font.headline,
                .foregroundColor: Color.label
            ]

            navigationBar.standardAppearance = appearance
        } else {
            // Bar Button Item
            let barButtonItemAppearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [Self.self])
            barButtonItemAppearance.setTitleTextAttributes([
                .font: Font.subheadline
                ], for: .normal)
            barButtonItemAppearance.setTitleTextAttributes([
                .font: Font.subheadline
                ], for: .highlighted)

            // Navigation Bar
            let navigationBarAppearance = UINavigationBar.appearance(whenContainedInInstancesOf: [Self.self])

            let chevronLayer = ChevronLayer()
            let backIndicatorImage = UIImage.image(from: chevronLayer)
            navigationBarAppearance.backIndicatorImage = backIndicatorImage
            navigationBarAppearance.backIndicatorTransitionMaskImage = backIndicatorImage

            navigationBarAppearance.titleTextAttributes = [
                .font: Font.headline,
                .foregroundColor: Color.label
            ]

            navigationBar.isTranslucent = false
            navigationBar.barTintColor = Color.background
            
        }
    }
}
