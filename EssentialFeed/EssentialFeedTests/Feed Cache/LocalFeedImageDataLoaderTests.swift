//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 13/08/2023.
//

import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?,Error>
    
    func retreive(dataForUrl url: URL,completion: @escaping (Result) -> Void)
}

final class LocalFeedImageDataLoader: FeedImageDataLoader {
    
    private let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        store.retreive(dataForUrl: url) { result in
            completion(result
                .mapError { _ in Error.failed }
                .flatMap { _ in .failure(Error.notFound) }
            )
        }
        return Task()
    }
    
    public enum Error: Swift.Error {
        case failed
        case notFound
    }
    
    private struct Task: FeedImageDataLoaderTask {
        func cancel() {}
    }
}

class LocalFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUnponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoreDataFromURL() {
        let (sut, store) = makeSUT()
        let url = anyURL
        
        _ = sut.loadImageData(from: url, completion: { _ in })
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
    }
    
    func test_loadImageDataFromURL_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: failed(), when: {
            let retrievalError = anyNSError
            store.complete(with: retrievalError)
        })
    }
    
    func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: notFound(), when: {
            store.complete(with: .none)
        })
    }
    
    // MARK:  Helpers
    
    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: LocalFeedImageDataLoader,store: FeedSpy) {
        let store = FeedSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut, store)
    }
    
    private func expect(
        _ sut: LocalFeedImageDataLoader,
        toCompleteWith expectedResult: FeedImageDataStore.Result,
        when action: (() -> Void),
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        
        _ = sut.loadImageData(from: anyURL) { receievedResult in
            switch(receievedResult,expectedResult) {
            case let (.success(receivedData),.success(expectedData)):
                XCTAssertEqual(receivedData, expectedData,file: file,line: line)
                
            case let (.failure(receviedError as LocalFeedImageDataLoader.Error),.failure(expectedError as LocalFeedImageDataLoader.Error)):
                XCTAssertEqual(receviedError, expectedError,file: file,line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receievedResult) instead",file: file,line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failed() -> FeedImageDataStore.Result {
        .failure(LocalFeedImageDataLoader.Error.failed)
    }
    
    private func notFound() -> FeedImageDataStore.Result {
        .failure(LocalFeedImageDataLoader.Error.notFound)
    }
    
    private class FeedSpy: FeedImageDataStore {
    
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }
        
        private var completions = [(FeedImageDataStore.Result) -> Void]()
        private(set) var receivedMessages = [Message]()
        
        func retreive(dataForUrl url: URL,completion: @escaping (FeedImageDataStore.Result) -> Void) {
            receivedMessages.append(.retrieve(dataFor: url))
            completions.append(completion)
        }
        
        func complete(with error: Error,at index: Int = 0) {
            completions[index](.failure(error))
        }
        
        func complete(with data: Data?,at index: Int = 0) {
            completions[index](.success(data))
        }
    }
}
