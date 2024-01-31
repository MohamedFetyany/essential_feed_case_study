//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 15/08/2023.
//

import Foundation

public final class LocalFeedImageDataLoader {
    
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader: FeedImageDataCache {
    
    public enum SaveError: Error {
        case failed
    }
    
    public func save(_ data: Data, for url: URL) throws {
        do {
            try store.insert(data, for: url)
        } catch { 
            throw SaveError.failed
        }
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    
    public func loadImageData(from url: URL) throws -> Data {
        do {
            if let imageData = try store.retreive(dataForUrl: url) {
                return imageData
            }
        } catch {
            throw LoadError.failed
        }
        throw LoadError.notFound
    }
    
    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }
}

