//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Mohamed Ibrahim on 04/12/2023.
//

import Foundation
import EssentialFeed

public class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    
    private let primary: FeedImageDataLoader
    private let fallback: FeedImageDataLoader
    
    public init(primary: FeedImageDataLoader,fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = TaskWrapper()
        task.wrapped = primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case let .success(data):
                completion(.success(data))
                
            case .failure:
                task.wrapped = self?.fallback.loadImageData(from: url,completion: completion)
            }
        }
        return task
    }
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapped: FeedImageDataLoaderTask?
        
        func cancel() {
            wrapped?.cancel()
        }
    }
}
