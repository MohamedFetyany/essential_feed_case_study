//
//  LocalFeedImageDataFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 13/08/2023.
//

import XCTest
import EssentialFeed

class LocalFeedImageDataFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUnponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsStoreDataFromURL() {
        let (sut, store) = makeSUT()
        let url = anyURL
        
        _ = try? sut.loadImageData(from: url)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
    }
    
    func test_loadImageDataFromURL_failsOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: failed(), when: {
            let retrievalError = anyNSError
            store.completeRetrieval(with: retrievalError)
        })
    }
    
    func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: notFound(), when: {
            store.completeRetrieval(with: .none)
        })
    }
    
    func test_loadImageDataFromURL_deliversStoredDataOnFoundData() {
        let (sut, store) = makeSUT()
        let foundData = anyData
        
        expect(sut, toCompleteWith: .success(foundData), when: {
            store.completeRetrieval(with: foundData)
        })
    }
    
    // MARK:  Helpers
    
    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: LocalFeedImageDataLoader,store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut, store)
    }
    
    private func expect(
        _ sut: LocalFeedImageDataLoader,
        toCompleteWith expectedResult: FeedImageDataStore.RetrievalResult,
        when action: (() -> Void),
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        action()
        
        let receievedResult = Result { try sut.loadImageData(from: anyURL) }
        switch(receievedResult,expectedResult) {
        case let (.success(receivedData),.success(expectedData)):
            XCTAssertEqual(receivedData, expectedData,file: file,line: line)
            
        case let (.failure(receviedError as LocalFeedImageDataLoader.LoadError),.failure(expectedError as LocalFeedImageDataLoader.LoadError)):
            XCTAssertEqual(receviedError, expectedError,file: file,line: line)
            
        default:
            XCTFail("Expected result \(expectedResult), got \(receievedResult) instead",file: file,line: line)
        }
    }
    
    private func failed() -> FeedImageDataStore.RetrievalResult {
        .failure(LocalFeedImageDataLoader.LoadError.failed)
    }
    
    private func notFound() -> FeedImageDataStore.RetrievalResult {
        .failure(LocalFeedImageDataLoader.LoadError.notFound)
    }
}
