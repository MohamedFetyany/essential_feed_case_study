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
        
        XCTAssertEqual(received.scheme, "https","scheme")
        XCTAssertEqual(received.host(), "base-url.com","host")
        XCTAssertEqual(received.path(), "/v1/feed","path")
        XCTAssertEqual(received.query(), "limit=10","query")
    }
}
