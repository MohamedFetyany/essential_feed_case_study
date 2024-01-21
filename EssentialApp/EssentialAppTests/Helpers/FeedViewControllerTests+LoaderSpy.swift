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

class LoaderSpy: FeedImageDataLoader {
    
    // MARK:  FeedLoader

    private var feedRequests = [PassthroughSubject<Paginated<FeedImage>,Error>]()
    
    var loadFeedCallCount: Int {
        feedRequests.count
    }
    
    private(set) var loadMoreCallCount = 0
        
    func loadPublisher() -> AnyPublisher<Paginated<FeedImage>,Error> {
        let publisher = PassthroughSubject<Paginated<FeedImage>,Error>()
        feedRequests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }
    
    func completeFeedLoading(with feed: [FeedImage] = [],at index: Int) {
        feedRequests[index].send(Paginated(items: feed,loadMore: { [weak self] _ in
            self?.loadMoreCallCount += 1
        }))
    }
    
    func completeFeedLoadingWithError(at index: Int) {
        let error = NSError(domain: "any error", code: 0)
        feedRequests[index].send(completion: .failure(error))
    }
    
    // MARK:  FeedImageDataLoader
    
    private(set) var imageRequests = [(url: URL,completion: (FeedImageDataLoader.Result) -> Void)]()
    
    var loadedImageURLs: [URL] {
        imageRequests.map { $0.url }
    }
    
    private(set) var cancelledImageURLs: [URL] = []
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        imageRequests.append((url,completion))
        return TaskSpy { [weak self] in
            self?.cancelledImageURLs.append(url)
        }
    }
    
    func completeImageLoading(with imagedata: Data = Data(),at index: Int) {
        imageRequests[index].completion(.success(imagedata))
    }
    
    func completeImageLoadingWithError(at index: Int) {
        let error = NSError(domain: "any error", code: 0)
        imageRequests[index].completion(.failure(error))
    }
    
    private struct TaskSpy: FeedImageDataLoaderTask {
        let cancelCallback: () -> Void
    
        func cancel() {
            cancelCallback()
        }
    }
}
