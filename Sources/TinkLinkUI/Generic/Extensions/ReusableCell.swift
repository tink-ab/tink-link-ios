import UIKit

protocol ReusableCell: AnyObject {
    static var reuseIdentifier: String { get }
}

extension ReusableCell where Self: UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableView {

    func registerReusableCell<T: UITableViewCell & ReusableCell>(ofType typeName: T.Type) {
        register(typeName, forCellReuseIdentifier: typeName.reuseIdentifier)
    }

    func dequeueReusableCell<T: UITableViewCell>(ofType typeName: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: typeName), for: indexPath) as? T else {
            fatalError("Can't dequeue cell with identifier \(String(describing: typeName))")
        }
        return cell
    }

    func dequeueReusableCell<T: UITableViewCell & ReusableCell>(ofType typeName: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: typeName.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Can't dequeue cell with identifier \(typeName.reuseIdentifier)")
        }
        return cell
    }
}

extension UICollectionView {

    func registerReusableCell<T: UICollectionViewCell & ReusableCell>(ofType typeName: T.Type) {
        register(typeName, forCellWithReuseIdentifier: typeName.reuseIdentifier)
    }

    func dequeueReusableCell<T: UICollectionViewCell & ReusableCell>(ofType typeName: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: typeName.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Can't dequeue cell with identifier \(typeName.reuseIdentifier)")
        }
        return cell
    }
}
