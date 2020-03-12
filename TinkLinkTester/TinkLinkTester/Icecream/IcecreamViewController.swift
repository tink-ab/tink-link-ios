import UIKit

protocol IcecreamViewControllerDelegate: AnyObject {
    func icecreamViewController(_ viewController: IcecreamViewController, willCloseWithReload: Bool)
}

final class IcecreamViewController: UITableViewController {

    weak var delegate: IcecreamViewControllerDelegate?

    let model = IcecreamModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        navigationItem.title = "🍦 Icecream"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
    }

    @objc private func done() {
        delegate?.icecreamViewController(self, willCloseWithReload: model.needsReload)
        dismiss(animated: true)
    }
}

extension IcecreamViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.sections[section].rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = model.sections[indexPath.section].rows[indexPath.row]
        cell.textLabel?.text = item.title
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = model.sections[indexPath.section].rows[indexPath.row]
        model.didSelect(identifier: item.identifier)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.sections[section].title
    }
}
