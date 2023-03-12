//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 12/03/2023.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    
    @discardableResult
    func insert(
        _ cache: (feed: [LocalFeedImage],timestamp: Date),
        to sut: FeedStore
    ) -> Error? {
        let exp = expectation(description: "waiting for cache retrieval ")
        var insertionError: Error?
        sut.insert(cache.feed,timestamp: cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.01)
        
        return insertionError
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "wait for cache deletion")
        var deletionError: Error?
        sut.deleteCachedFeed { recievedDeletionError in
            deletionError = recievedDeletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.01)
        
        return deletionError
    }
    
    func expect(
        _ sut: FeedStore,
        toRetrieve expectedResult: RetrieveCahedFeedResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "waiting for cache retrieval ")
        sut.retrieve { retrievedResult in
            switch (expectedResult,retrievedResult) {
            case (.empty,.empty),(.failure,.failure):
                break
                
            case let (.found(expectedFeed, expectedTimestamp),.found(retrievedFeed, retrievedTimestamp)):
                XCTAssertEqual(expectedFeed, retrievedFeed,file: file,line: line)
                XCTAssertEqual(expectedTimestamp, retrievedTimestamp,file: file,line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead",file: file,line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.01)
    }
    
    func expect(
        _ sut: FeedStore,
        toRetrieveTwice expectedResult: RetrieveCahedFeedResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        expect(sut, toRetrieve: expectedResult,file: file,line: line)
        expect(sut, toRetrieve: expectedResult,file: file,line: line)
    }
}
