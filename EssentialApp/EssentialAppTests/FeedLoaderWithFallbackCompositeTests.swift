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
        primary.load(completion: completion)
    }
}

class FeedLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let primaryLoader = LoaderStub(result: .success(primaryFeed))
        let fallbackLoader = LoaderStub(result: .success(fallbackFeed))
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoader,fallback: fallbackLoader)
        
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
    
    // MARK:  Helpers
    
    private struct LoaderStub: FeedLoader {
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
}
