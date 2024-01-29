//
//  NullStore.swift
//  EssentialApp
//
//  Created by Mohamed Ibrahim on 29/01/2024.
//

import Foundation
import EssentialFeed

class NullStore: FeedStore, FeedImageDataStore {
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        completion(.success(()))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        completion(.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        completion(.success(()))
    }
    
    func retreive(dataForUrl url: URL, completion: @escaping (RetrievalResult) -> Void) {
        completion(.success(.none))
    }
}
