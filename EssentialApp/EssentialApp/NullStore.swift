//
//  NullStore.swift
//  EssentialApp
//
//  Created by Mohamed Ibrahim on 29/01/2024.
//

import Foundation
import EssentialFeed

class NullStore {}

extension NullStore: FeedStore {
    
    func deleteCachedFeed() throws {}
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {}
    
    func retrieve() throws -> CachedFeed? { .none }
}

extension NullStore: FeedImageDataStore {
    
    func insert(_ data: Data,for url: URL) throws {}
    
    func retreive(dataForUrl url: URL) throws -> Data? { .none }
}
