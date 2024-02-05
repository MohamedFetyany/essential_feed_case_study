//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 01/02/2023.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage],timestamp: Date)

public protocol FeedStore {
    
    func deleteCachedFeed() throws
    func insert(_ feed: [LocalFeedImage],timestamp: Date) throws
    func retrieve() throws -> CachedFeed?

    typealias DeletionResult = Result<Void,Error>
    typealias DeletionCompletion = (DeletionResult) -> Void
    
    typealias InsertionResult = Result<Void,Error>
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    typealias RetrieveResult = Result<CachedFeed?,Error>
    typealias RetrievalCompletion = (RetrieveResult) -> Void

    @available(*,deprecated)
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    @available(*,deprecated)
    func insert(_ feed: [LocalFeedImage],timestamp: Date,completion: @escaping InsertionCompletion)
    
    @available(*,deprecated)
    func retrieve(completion: @escaping RetrievalCompletion)
}

public extension FeedStore {
    
    func deleteCachedFeed() throws {
        let group = DispatchGroup()
        group.enter()
        var result: DeletionResult!
        deleteCachedFeed {
            result = $0
            group.leave()
        }
        group.wait()
        
        try result.get()
    }
    
    func insert(_ feed: [LocalFeedImage],timestamp: Date) throws {
        let group = DispatchGroup()
        group.enter()
        var result: InsertionResult!
        insert(feed, timestamp: timestamp) {
            result = $0
            group.leave()
        }
        group.wait()
        
        try result.get()
    }
    
    func retrieve() throws -> CachedFeed? {
        let group = DispatchGroup()
        group.enter()
        var result: RetrieveResult!
        retrieve {
            result = $0
            group.leave()
        }
        group.wait()
        
        return try result.get()
    }
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {}
    
    func insert(_ feed: [LocalFeedImage],timestamp: Date,completion: @escaping InsertionCompletion) {}
    
    func retrieve(completion: @escaping RetrievalCompletion) {}
}
