//
//  InMemoryFeedStore.swift
//  EssentialAppTests
//
//  Created by Mohamed Ibrahim on 11/12/2023.
//

import Foundation
import EssentialFeed

class InMemoryFeedStore: FeedImageDataStore {
    
    private(set) var feedCache: CachedFeed? = nil
    private var feedImageDataCache: [URL: Data] = [:]
    
    init(feedCache: CachedFeed? = nil) {
        self.feedCache = feedCache
    }
    
    func insert(_ data: Data, for url: URL) throws {
        feedImageDataCache[url] = data
    }
    
    func retreive(dataForUrl url: URL) throws -> Data? {
        feedImageDataCache[url]
    }
}

extension InMemoryFeedStore: FeedStore {
    func deleteCachedFeed() throws {
        feedCache = nil
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        feedCache = CachedFeed(feed: feed,timestamp: timestamp)
    }
    
    func retrieve() throws -> CachedFeed? {
        feedCache
    }
}

extension InMemoryFeedStore {
    static var empty: InMemoryFeedStore {
        InMemoryFeedStore()
    }
    
    static var withExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CachedFeed(feed: [],timestamp: Date.distantPast))
    }
    
    static var withNonExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CachedFeed(feed: [],timestamp: Date()))
    }
}
