//
//  FeedEndpointTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 16/01/2024.
//

import XCTest
import EssentialFeed

final class FeedEndpointTests: XCTestCase {
    
    func test_feed_endPointURL() {
        let baseURL = URL(string: "https://base-url.com")!
        
        let received = FeedEndpoint.get.url(baseURL: baseURL)
        let expected = URL(string: "https://base-url.com/v1/feed")
        
        XCTAssertEqual(received, expected)
    }
}