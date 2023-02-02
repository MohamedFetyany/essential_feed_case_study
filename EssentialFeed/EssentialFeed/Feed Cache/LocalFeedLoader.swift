//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 01/02/2023.
//

import Foundation

public final class LocalFeedLoader {
    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    
    private let store: FeedStore
    private let currentDate: (() -> Date)
    private let calendar = Calendar(identifier: .gregorian)
    
    public init(store: FeedStore,currentDate: @escaping (() -> Date)) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ feed: [FeedImage],completion: @escaping ((SaveResult) -> Void)) {
        store.deleteCachedFeed { [weak self ] error in
            guard let self else { return }
            
            if let error {
                completion(error)
            } else {
                self.cache(feed,with: completion)
            }
        }
    }
    
    private func cache(_ feed: [FeedImage],with completion: @escaping ((SaveResult) -> Void)) {
        store.insert(feed.toLocal(),timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        }
    }
    
    public func load(completion: @escaping ((LoadResult) -> Void)) {
        store.retrieve { [unowned self] result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .found (feed,timestamp) where self.validate(timestamp):
                completion(.success(feed.toModels()))
                
            case .found ,.empty:
                completion(.success([]))
            }
        }
    }
    
    private var maxCacheAgeInDays: Int {
        7
    }
    
    private func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        
        return currentDate() < maxCacheAge
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