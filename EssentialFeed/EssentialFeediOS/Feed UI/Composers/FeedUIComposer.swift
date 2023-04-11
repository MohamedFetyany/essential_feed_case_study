//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 11/04/2023.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
    
    private init() {}
    
    public static func feedComposeWith(feedLoader: FeedLoader,imageLoader: FeedImageDataLoader) -> FeedViewController {
        let refreshController = FeedRefreshController(feedLoader: feedLoader)
        let feedViewController = FeedViewController(refreshController: refreshController)
        refreshController.onRefresh  = { [weak feedViewController] feed in
            feedViewController?.tableModel = feed.map { image in
                FeedImageCellController(model: image, imageLoader: imageLoader)
            }
        }
        return feedViewController
    }
}
