import UIKit
import TinkLink

final class FormTableViewController: UITableViewController {

    var onSubmit: (() -> Void)?
    var formDidChange: (() -> Void)?

    private(set) var form: Form

    private var currentScrollPos: CGFloat?
    private var errors: [IndexPath: Form.Field.ValidationError] = [:]

    init(form: Form) {
        self.form = form
        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .clear
        tableView.registerReusableCell(ofType: FormFieldTableViewCell.self)
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let field = form.fields[indexPath.item]

        let cell = tableView.dequeueReusableCell(ofType: FormFieldTableViewCell.self, for: indexPath)
        var viewModel = FormFieldTableViewCell.ViewModel(field: field)
//        switch prefillStrategy {
//        case .username(value: let name, isEditable: let isEditable):
//            if indexPath.row == 0 {
//                var testField = field
//                testField.text = name
//                guard testField.isValid else { break }
//                viewModel.text = name
//                viewModel.isEditable = isEditable ? field.attributes.isEditable : false
//            }
//        case .none:
//            break
//        }
        cell.configure(with: viewModel)
        cell.delegate = self
        cell.setError(with: errors[indexPath]?.localizedDescription)
        cell.textField.returnKeyType = indexPath.row < (form.fields.count - 1) ? .next : .continue
        return cell
    }
}

// MARK: - TextFieldCellDelegate
extension FormTableViewController: FormFieldTableViewCellDelegate {
    func formFieldCellShouldReturn(_ cell: FormFieldTableViewCell) -> Bool {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return true
        }

        let lastIndexItem = form.fields.count - 1
        if lastIndexItem == indexPath.item {
            onSubmit?()
            return true
        }

        let nextIndexPath = IndexPath(row: indexPath.item + 1, section: indexPath.section)

        guard form.fields.count > nextIndexPath.item,
            form.fields[indexPath.item + 1].attributes.isEditable,
            let nextCell = tableView.cellForRow(at: nextIndexPath)
            else {
                cell.resignFirstResponder()
                return true
        }

        nextCell.becomeFirstResponder()

        return false
    }

    func formFieldCell(_ cell: FormFieldTableViewCell, willChangeToText text: String) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        form.fields[indexPath.item].text = text
        errors[indexPath] = nil
        currentScrollPos = tableView.contentOffset.y
        tableView.beginUpdates()
        cell.setError(with: nil)
        tableView.endUpdates()
        currentScrollPos = nil
        formDidChange?()
    }

    func formFieldCellDidEndEditing(_ cell: FormFieldTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        let field = form.fields[indexPath.item]

        do {
            try field.validate()
            errors[indexPath] = nil
        } catch let error as Form.Field.ValidationError {
            errors[indexPath] = error
        } catch {
            print("Unknown error \(error).")
        }
        currentScrollPos = tableView.contentOffset.y
        tableView.reloadRows(at: [indexPath], with: .automatic)
        currentScrollPos = nil
        formDidChange?()
    }

    // To fix the issue for scroll view jumping while animating the cell, inspired by
    // https://stackoverflow.com/questions/33789807/uitableview-jumps-up-after-begin-endupdates-when-using-uitableviewautomaticdimen
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Force the tableView to stay at scroll position until animation completes
        if let currentScrollPos = currentScrollPos {
            tableView.setContentOffset(CGPoint(x: 0, y: currentScrollPos), animated: false)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return form.fields.count
    }
}
