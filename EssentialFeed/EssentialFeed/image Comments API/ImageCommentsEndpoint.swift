//
//  ImageCommentsEndpoint.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 16/01/2024.
//

import Foundation

public enum ImageCommentsEndpoint {
    case get(UUID)
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(id):
            return baseURL.appending(path: "/v1/image/\(id)/comments")
        }
    }
}
