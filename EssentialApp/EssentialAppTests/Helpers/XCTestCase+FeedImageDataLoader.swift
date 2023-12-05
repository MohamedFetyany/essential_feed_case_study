//
//  XCTestCase+FeedImageDataLoader.swift
//  EssentialAppTests
//
//  Created by Mohamed Ibrahim on 05/12/2023.
//

import XCTest
import EssentialFeed

protocol FeedImageDataLoaderTestCase: XCTestCase {}

extension FeedImageDataLoaderTestCase {
    
    func expect(
        _ sut: FeedImageDataLoader,
        toCompleteWith expectedResult: FeedImageDataLoader.Result,
        when action: (() -> Void),
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        _ = sut.loadImageData(from: anyURL) { receivedResult in
            switch (receivedResult,expectedResult) {
            case let (.success(receviedData),.success(expectedData)):
                XCTAssertEqual(receviedData, expectedData,file: file,line: line)
                
            case (.failure,.failure):
                break
                
            default:
                XCTFail("Expected \(expectedResult) but, got \(receivedResult) instead",file: file,line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
    }
}
