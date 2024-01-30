//
//  ListViewControllerTests+LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by Mohamed Ibrahim on 06/04/2023.
//

import Foundation
import Combine
import EssentialFeed
import EssentialFeediOS

class LoaderSpy {
    
    // MARK:  FeedLoader
    
    private var feedRequests = [PassthroughSubject<Paginated<FeedImage>,Error>]()
    
    var loadFeedCallCount: Int { feedRequests.count }
    
    func loadPublisher() -> AnyPublisher<Paginated<FeedImage>,Error> {
        let publisher = PassthroughSubject<Paginated<FeedImage>,Error>()
        feedRequests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }
    
    func completeFeedLoading(with feed: [FeedImage] = [],at index: Int) {
        feedRequests[index].send(Paginated(items: feed,loadMorePublisher: { [weak self] in
            self?.loadMorePublisher() ?? Empty().eraseToAnyPublisher()
        }))
        feedRequests[index].send(completion: .finished)
    }
    
    func completeFeedLoadingWithError(at index: Int) {
        feedRequests[index].send(completion: .failure(anyNSError))
    }
    
    // MARK:  LoadMoreFeedLoader
    
    private var loadMoreRequests = [PassthroughSubject<Paginated<FeedImage>,Error>]()
    
    var loadMoreCallCount: Int { loadMoreRequests.count }
    
    func loadMorePublisher() -> AnyPublisher<Paginated<FeedImage>,Error> {
        let publisher = PassthroughSubject<Paginated<FeedImage>,Error>()
        loadMoreRequests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }
    
    func completeLoadMore(with feed: [FeedImage] = [],isLastPage: Bool = false,at index: Int) {
        loadMoreRequests[index].send(Paginated(
            items: feed,
            loadMorePublisher: isLastPage ? nil : { [weak self] in
                self?.loadMorePublisher() ?? Empty().eraseToAnyPublisher()
            }))
    }
    
    func completeLoadMoreWithError(at index: Int) {
        loadMoreRequests[index].send(completion: .failure(anyNSError))
    }
    
    // MARK:  FeedImageDataLoader
    
    private(set) var imageRequests = [(url: URL,publisher: PassthroughSubject<Data,Error>)]()

    var loadedImageURLs: [URL] { imageRequests.map { $0.url } }
    
    private(set) var cancelledImageURLs: [URL] = []

    func loadImageDataPublisher(from url: URL) -> AnyPublisher<Data,Error> {
        let publisher = PassthroughSubject<Data,Error>()
        imageRequests.append((url,publisher))
        return publisher.handleEvents(receiveCancel: { [weak self] in
            self?.cancelledImageURLs.append(url)
        }).eraseToAnyPublisher()
    }
    
    func completeImageLoading(with imagedata: Data = Data(),at index: Int) {
        imageRequests[index].publisher.send(imagedata)
        imageRequests[index].publisher.send(completion: .finished)
    }
    
    func completeImageLoadingWithError(at index: Int) {
        imageRequests[index].publisher.send(completion: .failure(anyNSError))
    }
}
