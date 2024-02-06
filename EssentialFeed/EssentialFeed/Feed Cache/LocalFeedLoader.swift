//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 01/02/2023.
//

import Foundation

public final class LocalFeedLoader {
        
    private let store: FeedStore
    private let currentDate: (() -> Date)
    private let calendar = Calendar(identifier: .gregorian)
    
    public init(store: FeedStore,currentDate: @escaping (() -> Date)) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader {
    public typealias ValidateResult = Result<Void,Error>
    
    private struct InvalidCache: Error {}
    
    public func validateCache(completion: @escaping (ValidateResult) -> Void) {
        completion(ValidateResult {
            do {
                if let cache = try store.retrieve(), !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()) {
                    throw InvalidCache()
                }
            } catch {
                try store.deleteCachedFeed()
            }
        })
    }
}

extension LocalFeedLoader: FeedCache {
    
    public func save(_ feed: [FeedImage]) throws {
        try store.deleteCachedFeed()
        try store.insert(feed.toLocal(), timestamp: currentDate())
    }
}

extension LocalFeedLoader {
    
    public typealias LoadResult = Swift.Result<[FeedImage],Error>
    
    public func load(completion: @escaping ((LoadResult) -> Void)) {
        completion(LoadResult {
            if let cache = try store.retrieve(),FeedCachePolicy.validate(cache.timestamp,against: self.currentDate()) {
                return cache.feed.toModels()
            }
            
            return []
        })
    }
}

private extension Array where Element == FeedImage {
    
    func toLocal() -> [LocalFeedImage] {
        map {
            LocalFeedImage(id: $0.id,description: $0.description,location: $0.location ,url: $0.url)
        }
    }
}

private extension Array where Element == LocalFeedImage {
    
    func toModels() -> [FeedImage] {
        map {
            FeedImage(id: $0.id,description: $0.description,location: $0.location ,url: $0.url)
        }
    }
}
