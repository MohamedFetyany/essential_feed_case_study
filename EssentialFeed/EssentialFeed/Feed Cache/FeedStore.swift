//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 01/02/2023.
//

import Foundation

public enum RetrieveCahedFeedResult {
    case empty
    case found(feed: [LocalFeedImage],timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrieveCahedFeedResult) -> Void

    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ feed: [LocalFeedImage],timestamp: Date,completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
