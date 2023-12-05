//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 05/12/2023.
//

import Foundation

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void,Error>
    
    func save(_ data: Data,for url: URL,completion: @escaping (Result) -> Void)
}
