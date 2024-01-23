//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 16/01/2024.
//

import Foundation

public enum FeedEndpoint {
    case get
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            var component = URLComponents()
            component.scheme = baseURL.scheme
            component.host = baseURL.host()
            component.path = baseURL.path() + "/v1/feed"
            component.queryItems = [
                URLQueryItem(name: "limit", value: "10")
            ]
            return component.url!
        }
    }
}
