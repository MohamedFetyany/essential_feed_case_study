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

public final class CommentsUIComposer {
    
    private init() {}
    
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[FeedImage],FeedViewAdapter>
    
    public static func commentsComposeWith(
        commentsLoader: @escaping (() -> AnyPublisher<[FeedImage],Error> )
    ) -> ListViewController {
        
        let presentationAdapter = FeedPresentationAdapter(loader: commentsLoader)
        let feedController = makeFeedViewController(title: FeedPresenter.title)
        feedController.onRefresh = presentationAdapter.loadResource
        
        presentationAdapter.presenter = LoadResourcePresenter<[FeedImage],FeedViewAdapter>(
            resourceView: FeedViewAdapter(controller: feedController,imageLoader: { _ in Empty<Data,Error>().eraseToAnyPublisher() }),
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
