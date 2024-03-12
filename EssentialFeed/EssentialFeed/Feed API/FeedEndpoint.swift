//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 16/01/2024.
//

import Foundation

public enum FeedEndpoint {
    case get(after: FeedImage? = nil)
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(image):
            var component = URLComponents()
            component.scheme = baseURL.scheme
            component.host = baseURL.host()
            component.path = baseURL.path() + "/v1/feed"
            component.queryItems = [
                URLQueryItem(name: "limit", value: "10"),
                image.map { URLQueryItem(name: "after_id", value: $0.id.uuidString) }
            ].compactMap { $0 }
            return component.url!
        }
    }
}
