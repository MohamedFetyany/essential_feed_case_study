//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 14/03/2023.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
    
    public init() {}

    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    public func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
}
