//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 21/08/2023.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        
    }
    
    public func retreive(dataForUrl url: URL, completion: @escaping (RetrievalResult) -> Void) {
        completion(.success(.none))
    }
}
