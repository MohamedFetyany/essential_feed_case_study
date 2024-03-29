//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 21/08/2023.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        perform { context in
            completion(Result {
                try ManagedFeedImage.first(with: url, in: context)
                    .map { $0.data = data }
                    .map(context.save)
            })
        }
    }
    
    public func retreive(dataForUrl url: URL, completion: @escaping (RetrievalResult) -> Void) {
        perform { context in
            completion(Result {
                 try ManagedFeedImage.first(with: url, in: context)?.data
            })
        }
    }
}
