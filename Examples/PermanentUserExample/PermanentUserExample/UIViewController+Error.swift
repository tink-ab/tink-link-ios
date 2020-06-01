import UIKit

extension UIViewController {
    func showAlert(for error: Error) {
        let localizedError = error as? LocalizedError
        let alertController = UIAlertController(
            title: localizedError?.errorDescription ?? "Error",
            message: localizedError?.failureReason ?? error.localizedDescription,
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)

        present(alertController, animated: true)
    }
}
