//
//  FeedViewControllerTests+LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by Mohamed Ibrahim on 06/04/2023.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

class LoaderSpy: FeedLoader, FeedImageDataLoader {
    
    // MARK:  FeedLoader

    private var feedRequests = [(FeedLoader.Result) -> Void]()
    
    var loadFeedCallCount: Int {
        feedRequests.count
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        feedRequests.append(completion)
    }
    
    func completeFeedLoading(with feed: [FeedImage] = [],at index: Int) {
        feedRequests[index](.success(feed))
    }
    
    func completeFeedLoadingWithError(at index: Int) {
        let error = NSError(domain: "any error", code: 0)
        feedRequests[index](.failure(error))
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
