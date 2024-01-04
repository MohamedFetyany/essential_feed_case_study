//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 11/04/2023.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class FeedUIComposer {
    
    private init() {}
    
    public static func feedComposeWith(
        feedLoader: @escaping (() -> AnyPublisher<[FeedImage],Error> ),
        imageLoader: @escaping ((URL) -> FeedImageDataLoader.Publisher)
    ) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
        
        let feedController = makeFeedViewController(delegate: presentationAdapter, title: FeedPresenter.title)
        
        presentationAdapter.presenter = LoadResourcePresenter<[FeedImage],FeedViewAdapter>(
            resourceView: FeedViewAdapter(controller: feedController,imageLoader: imageLoader),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: FeedPresenter.map
        )
        return feedController
    }
    
    private static func makeFeedViewController(delegate: FeedViewControllerDelegate,title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController: FeedViewController  = storyboard.instantiateViewController(identifier: "FeedViewController")
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}
