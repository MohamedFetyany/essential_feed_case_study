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
        let feedPresenter = FeedPresenter(feedLoader: feedLoader)
        let refreshController = FeedRefreshController(presenter: feedPresenter)
        let feedViewController = FeedViewController(refreshController: refreshController)
        feedPresenter.loadingView = refreshController
        feedPresenter.feedView = FeedViewAdapter(controller: feedViewController, imageLoader: imageLoader)
        return feedViewController
    }
}

private final class FeedViewAdapter: FeedView {
    
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(feed: [FeedImage]) {
        controller?.tableModel = feed.map { model in
            FeedImageCellController(viewModel: FeedImageViewModel(model: model, imageLoader: imageLoader,imageTransformer: UIImage.init))
        }
    }
}
