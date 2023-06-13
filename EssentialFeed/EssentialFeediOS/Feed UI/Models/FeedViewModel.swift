//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 13/06/2023.
//

import Foundation
import EssentialFeed

class FeedViewModel {
    typealias Observer<T> = ((T) -> Void)
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }

    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?
    
    func loadFeed() {
        onLoadingStateChange?(true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
