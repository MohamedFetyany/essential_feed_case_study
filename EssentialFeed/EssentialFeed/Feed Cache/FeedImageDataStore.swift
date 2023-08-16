//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 15/08/2023.
//

import Foundation

public protocol FeedImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?,Error>
    typealias InsertionResult = Swift.Result<Void,Error>
    
    func insert(_ data: Data,for url: URL,completion: @escaping (InsertionResult) -> Void)
    func retreive(dataForUrl url: URL,completion: @escaping (RetrievalResult) -> Void)
}
