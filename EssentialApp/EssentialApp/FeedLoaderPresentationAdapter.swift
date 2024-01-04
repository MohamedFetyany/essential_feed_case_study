//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 18/07/2023.
//

import Combine
import EssentialFeed
import EssentialFeediOS

public final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    
    var presenter: LoadResourcePresenter<[FeedImage],FeedViewAdapter>?
    private var cancellable: AnyCancellable?
    private let feedLoader: (() -> AnyPublisher<[FeedImage],Error>)
    
    public init(feedLoader: @escaping (() -> AnyPublisher<[FeedImage],Error>)) {
        self.feedLoader = feedLoader
    }
    
    public func didRequestFeedRefresh() {
        presenter?.didStartLoading()
        
        cancellable = feedLoader()
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break
                        
                    case let .failure(error):
                        self?.presenter?.didFinishLoading(with: error)
                    }
                } ,receiveValue: { [weak self] feed in
                    self?.presenter?.didFinishLoading(with: feed)
                })
    }
}
