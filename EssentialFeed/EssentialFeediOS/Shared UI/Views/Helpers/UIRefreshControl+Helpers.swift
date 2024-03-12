//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 25/07/2023.
//

import UIKit

extension UIRefreshControl {
    func update(isRefrehing: Bool) {
        isRefrehing ? beginRefreshing() : endRefreshing()
    }
}
