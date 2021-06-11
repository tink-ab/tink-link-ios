//
//  File.swift
//  
//
//  Created by Menghao Zhang on 2021-06-11.
//

import UIKit

extension NSLayoutConstraint {
    func withPriority(_ layoutPriority: UILayoutPriority) -> NSLayoutConstraint {
        priority = layoutPriority
        return self
    }
}
