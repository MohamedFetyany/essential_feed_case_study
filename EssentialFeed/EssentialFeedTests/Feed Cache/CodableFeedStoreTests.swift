//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 01/03/2023.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion){
        completion(.empty)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "waiting for cache retrieval ")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
                
            default:
                XCTFail("Expected emtpy result,got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.01)
    }
}
