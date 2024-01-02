//
//  FeedImageDataMapper.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 02/01/2024.
//

import Foundation

public final class FeedImageDataMapper {
        
    public static func map(_ data: Data,from response: HTTPURLResponse) throws -> Data {
        guard response.isOK && !data.isEmpty else { throw Error.invalidData }
        return data
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
}
