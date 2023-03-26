//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 10/01/2023.
//

import Foundation

public typealias LoadFeedResult = Swift.Result<[FeedImage],Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
