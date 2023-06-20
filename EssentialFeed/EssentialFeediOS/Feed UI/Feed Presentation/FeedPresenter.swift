//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 19/06/2023.
//

import EssentialFeed

protocol FeedView {
    func display(feed: [FeedImage])
}

protocol FeedLoadingView: AnyObject {
    func display(isLoading: Bool)
}

class FeedPresenter {
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    weak var loadingView: FeedLoadingView?
    var feedView: FeedView?
    
    func loadFeed() {
        loadingView?.display(isLoading: true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(feed: feed)
            }
            self?.loadingView?.display(isLoading: false)
        }
    }
}
