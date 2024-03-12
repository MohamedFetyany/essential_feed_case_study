//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 06/04/2023.
//

import Foundation

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}
