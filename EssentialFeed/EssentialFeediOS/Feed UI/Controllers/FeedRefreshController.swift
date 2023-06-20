//
//  FeedRefreshController.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 09/04/2023.
//

import UIKit

final class FeedRefreshController: NSObject, FeedLoadingView {
    
    private(set) lazy var view = loadView()
    
    private let presenter : FeedPresenter
    
    init(presenter: FeedPresenter) {
        self.presenter = presenter
    }
    
    @objc func refresh() {
        presenter.loadFeed()
    }
    
    func display(isLoading: Bool) {
        if isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
