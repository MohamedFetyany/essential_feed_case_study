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
    
    func insert(_ data: Data,for url: URL) throws
    func retreive(dataForUrl url: URL) throws -> Data?
    
    @available(*,deprecated)
    func insert(_ data: Data,for url: URL,completion: @escaping (InsertionResult) -> Void)
    
    @available(*,deprecated)
    func retreive(dataForUrl url: URL,completion: @escaping (RetrievalResult) -> Void)
}

public extension FeedImageDataStore {
    
    func insert(_ data: Data,for url: URL) throws {
        let group = DispatchGroup()
        group.enter()
        var result: InsertionResult!
        insert(data, for: url) {
            result = $0
            group.leave()
        }
        group.wait()
        return try result.get()
    }
    
    func retreive(dataForUrl url: URL) throws -> Data? {
        let group = DispatchGroup()
        group.enter()
        var result: RetrievalResult!
        retreive(dataForUrl: url) {
            result = $0
            group.leave()
        }
        group.wait()
        return try result.get()
    }
    
    func insert(_ data: Data,for url: URL,completion: @escaping (InsertionResult) -> Void) {}
    func retreive(dataForUrl url: URL,completion: @escaping (RetrievalResult) -> Void){}
}
