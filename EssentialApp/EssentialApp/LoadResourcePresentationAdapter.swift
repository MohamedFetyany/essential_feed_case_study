//
//  LoadResourcePresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 18/07/2023.
//

import Combine
import EssentialFeed
import EssentialFeediOS

public final class LoadResourcePresentationAdapter<Resource,View: ResourceView> {
    
    var presenter: LoadResourcePresenter<Resource,View>?
    private var cancellable: AnyCancellable?
    private let loader: (() -> AnyPublisher<Resource,Error>)
    
    public init(loader: @escaping (() -> AnyPublisher<Resource,Error>)) {
        self.loader = loader
    }
    
    public func loadResource() {
        presenter?.didStartLoading()
        
        cancellable = loader()
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break
                        
                    case let .failure(error):
                        self?.presenter?.didFinishLoading(with: error)
                    }
                } ,receiveValue: { [weak self] resource in
                    self?.presenter?.didFinishLoading(with: resource)
                })
    }
}

extension LoadResourcePresentationAdapter: FeedViewControllerDelegate {
    public func didRequestFeedRefresh() {
        loadResource()
    }
}
