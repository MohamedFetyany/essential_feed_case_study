//
//  FeedRefreshController.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 09/04/2023.
//

import UIKit

final class FeedRefreshController: NSObject {
    
    private(set) lazy var view = binded(UIRefreshControl())
    
    private let viewModel : FeedViewModel
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }
    
    @objc func refresh() {
        viewModel.loadFeed()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onChange = { viewModel in
            if viewModel.isLoading {
                view.beginRefreshing()
            } else {
                view.endRefreshing()
            }
        }
        
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
