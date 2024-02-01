//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 15/08/2023.
//

import Foundation

public protocol FeedImageDataStore {
    func insert(_ data: Data,for url: URL) throws
    func retreive(dataForUrl url: URL) throws -> Data?
}
