//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 05/12/2023.
//

import Foundation

public protocol FeedCache {
    func save(_ feed: [FeedImage]) throws
}
