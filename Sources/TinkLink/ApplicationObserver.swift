#if os(iOS)
import UIKit
#endif
import Foundation

class ApplicationObserver {

    var willResignActive: (() -> Void)?
    var didBecomeActive: (() -> Void)?

    var observers: [NSObjectProtocol] = []

    init() {
        #if os(iOS)
        let didBecomeActiveObserver = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] _ in
            self?.didBecomeActive?()
        }

        let willResignActiveObserver = NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { [weak self] _ in
            self?.willResignActive?()
        }
        
        observers = [didBecomeActiveObserver, willResignActiveObserver]
        #endif
    }

    deinit {
        #if os(iOS)
        observers.forEach(NotificationCenter.default.removeObserver)
        #endif
    }
}
