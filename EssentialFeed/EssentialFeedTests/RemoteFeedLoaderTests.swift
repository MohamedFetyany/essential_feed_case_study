//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 11/01/2023.
//

import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestedDataFromURL() {
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
}
