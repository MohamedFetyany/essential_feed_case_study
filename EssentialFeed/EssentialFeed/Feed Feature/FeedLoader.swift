//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 10/01/2023.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage],Error>
    
    func load(completion: @escaping (Result) -> Void)
}
