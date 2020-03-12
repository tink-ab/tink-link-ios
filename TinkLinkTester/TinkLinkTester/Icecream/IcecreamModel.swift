import Foundation
import TinkLinkUI

final class IcecreamModel {

    private(set) var needsReload = false

    enum RowIdentifier {
        case theme(AppearanceProvider?)
    }

    struct Section {
        let title: String?
        let rows: [Row]
    }

    struct Row {
        let title: String?
        let identifier: RowIdentifier
    }

    lazy private(set) var sections = makeSections()

    private func makeSections() -> [Section] {
        [Section(title: "Theme", rows: [
            Row(title: "Default", identifier: .theme(nil)),
            Row(title: "Chewinggum", identifier: .theme(.chewinggum)),
            Row(title: "Strict", identifier: .theme(.strict))
        ])]
    }

    func didSelect(identifier: RowIdentifier) {
        switch identifier {
        case .theme(let theme):
            needsReload = true
            Appearance.provider = theme
        }
    }
}
