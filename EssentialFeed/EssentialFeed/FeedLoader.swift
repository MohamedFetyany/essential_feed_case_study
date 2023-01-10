//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 10/01/2023.
//

import Foundation

enum LoadFeedResult{
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
