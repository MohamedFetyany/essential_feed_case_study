//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 10/01/2023.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
