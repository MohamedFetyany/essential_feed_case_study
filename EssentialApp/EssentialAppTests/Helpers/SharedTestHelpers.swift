//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Mohamed Ibrahim on 04/12/2023.
//

import Foundation
import EssentialFeed

var anyURL: URL {
    URL(string: "https://a-url.com")!
}

var anyNSError: NSError {
    NSError(domain: "any error", code: 0)
}

var anyData: Data {
    Data("any data".utf8)
}

func uniqueFeed() -> [FeedImage] {
    [FeedImage(id: UUID(), description: "any", location: "any", url: anyURL)]
}
