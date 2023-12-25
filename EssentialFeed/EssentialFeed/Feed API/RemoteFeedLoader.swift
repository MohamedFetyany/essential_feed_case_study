//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 12/01/2023.
//

import Foundation

public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>

public extension RemoteFeedLoader {
    convenience init(url: URL,client: HTTPClient) {
        self.init(url: url, client: client, mapper: FeedItemsMapper.map)
    }
}
