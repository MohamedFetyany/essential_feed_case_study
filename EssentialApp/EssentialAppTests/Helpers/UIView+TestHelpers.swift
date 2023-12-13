//
//  UIView+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Mohamed Ibrahim on 13/12/2023.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
