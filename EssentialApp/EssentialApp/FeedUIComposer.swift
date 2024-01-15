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
    
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[FeedImage],FeedViewAdapter>
    
    public static func feedComposeWith(
        feedLoader: @escaping (() -> AnyPublisher<[FeedImage],Error> ),
        imageLoader: @escaping ((URL) -> FeedImageDataLoader.Publisher),
        selection: @escaping ((FeedImage) -> Void)
    ) -> ListViewController {
        
        let presentationAdapter = FeedPresentationAdapter(loader: feedLoader)
        let feedController = makeFeedViewController(title: FeedPresenter.title)
        feedController.onRefresh = presentationAdapter.loadResource
        
        presentationAdapter.presenter = LoadResourcePresenter<[FeedImage],FeedViewAdapter>(
            resourceView: FeedViewAdapter(controller: feedController,imageLoader: imageLoader,selection: selection),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: FeedPresenter.map
        )
        return feedController
    }
    
    private static func makeFeedViewController(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController: ListViewController  = storyboard.instantiateViewController(identifier: "FeedViewController")
        feedController.title = title
        return feedController
    }
}
