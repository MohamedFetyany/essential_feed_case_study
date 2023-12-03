//
//  FeedLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Mohamed Ibrahim on 03/12/2023.
//

import XCTest
import EssentialFeed

class FeedLoaderWithFallbackComposite: FeedLoader {
    
    private let primary: FeedLoader
    private let fallback: FeedLoader
    
    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load { [weak self] result in
            switch result {
            case .success:
                completion(result)
                
            case .failure:
                self?.fallback.load(completion: completion)

            }
        }
    }
}

class FeedLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
        
        let exp = expectation(description: "Waiting for load completion")
        sut.load { result in
            switch result {
            case let .success(expectedFeed):
                XCTAssertEqual(expectedFeed, primaryFeed)
                
            case .failure:
                XCTFail("Expected successful load feed result, got \(result) instead.")
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_load_deliversFallbackFeedOnPrimaryLoaderFailure() {
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .failure(anyNSError), fallbackResult: .success(fallbackFeed))
        
        let exp = expectation(description: "Waiting for load completion")
        sut.load { result in
            switch result {
            case let .success(expectedFeed):
                XCTAssertEqual(expectedFeed, fallbackFeed)
                
            case .failure:
                XCTFail("Expected successful load feed result, got \(result) instead.")
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    // MARK:  Helpers
    
    private func makeSUT(
        primaryResult: FeedLoader.Result,
        fallbackResult: FeedLoader.Result,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> FeedLoader {
        let primaryLoader = LoaderStub(result: primaryResult)
        let fallbackLoader = LoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader,fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader,file: file,line: line)
        trackForMemoryLeaks(fallbackLoader,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return sut
    }
    
    private class LoaderStub: FeedLoader {
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }
    
    func uniqueFeed() -> [FeedImage] {
        [FeedImage(id: UUID(), description: "any", location: "any", url:  URL(string: "https://any-url.com")!)]
    }
    
    func trackForMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance,"instance should have been deallocated. Potential memory leak.",file: file,line: line)
        }
    }
    
    var anyNSError: NSError {
        NSError(domain: "any error", code: 0)
    }
}