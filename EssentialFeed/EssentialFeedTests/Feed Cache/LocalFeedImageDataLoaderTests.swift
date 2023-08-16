//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 13/08/2023.
//

import XCTest
import EssentialFeed

class LocalFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUnponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_saveImageDataFromURL_requestsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL
        let data = Data()
        
        sut.save(data, for: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.insert(data: data,for: url)])
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
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut, store) = makeSUT()
        let foundData = anyData
        
        var received = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL) { received.append($0) }
        task.cancel()
        
        store.completeRetrieval(with: foundData)
        store.completeRetrieval(with: .none)
        store.completeRetrieval(with: anyNSError)
        
        XCTAssertTrue(received.isEmpty,"Expected no received results after cancelling task")
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = StoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var received = [FeedImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL) { received.append($0) }
        
        sut = nil
        store.completeRetrieval(with: anyData)
        
        XCTAssertTrue(received.isEmpty, "Expected  no received results after instance has been deallocated")
    }
    
    // MARK:  Helpers
    
    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: LocalFeedImageDataLoader,store: StoreSpy) {
        let store = StoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut, store)
    }
    
    private func never(file: StaticString = #filePath, line: UInt = #line) {
        XCTFail("Expected no no invocations", file: file,line: line)
    }
    
    private func expect(
        _ sut: LocalFeedImageDataLoader,
        toCompleteWith expectedResult: FeedImageDataStore.RetrievalResult,
        when action: (() -> Void),
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        
        _ = sut.loadImageData(from: anyURL) { receievedResult in
            switch(receievedResult,expectedResult) {
            case let (.success(receivedData),.success(expectedData)):
                XCTAssertEqual(receivedData, expectedData,file: file,line: line)
                
            case let (.failure(receviedError as LocalFeedImageDataLoader.LoadError),.failure(expectedError as LocalFeedImageDataLoader.LoadError)):
                XCTAssertEqual(receviedError, expectedError,file: file,line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receievedResult) instead",file: file,line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failed() -> FeedImageDataStore.RetrievalResult {
        .failure(LocalFeedImageDataLoader.LoadError.failed)
    }
    
    private func notFound() -> FeedImageDataStore.RetrievalResult {
        .failure(LocalFeedImageDataLoader.LoadError.notFound)
    }
    
    private class StoreSpy: FeedImageDataStore {
    
        enum Message: Equatable {
            case retrieve(dataFor: URL)
            case insert(data: Data,for: URL)
        }
        
        private var retrievalcompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
        private(set) var receivedMessages = [Message]()
        
        func retreive(dataForUrl url: URL,completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
            receivedMessages.append(.retrieve(dataFor: url))
            retrievalcompletions.append(completion)
        }
        
        func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
            receivedMessages.append(.insert(data: data, for: url))
        }
        
        func completeRetrieval(with error: Error,at index: Int = 0) {
            retrievalcompletions[index](.failure(error))
        }
        
        func completeRetrieval(with data: Data?,at index: Int = 0) {
            retrievalcompletions[index](.success(data))
        }
    }
}
