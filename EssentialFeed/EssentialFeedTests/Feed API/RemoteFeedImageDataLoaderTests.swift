//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 01/08/2023.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
    
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    @discardableResult
    func loadImageData(from url: URL,completion: @escaping ((FeedImageDataLoader.Result) -> Void)) -> FeedImageDataLoaderTask {
        HTTPTaskWrapper(wrapped:  client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data,response)):
                if response.statusCode == 200 , !data.isEmpty {
                    completion(.success(data))
                } else {
                    completion(.failure(Error.invalidData))
                }
                
            case let .failure(error): completion(.failure(error))
            }
        })
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    private struct HTTPTaskWrapper: FeedImageDataLoaderTask {
        let wrapped: HTTPClientTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
}

class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotPerformAnyURLRequest() {
        let (_ ,client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url,url])
    }
    
    func test_loadImageDataFromURL_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let clientError = NSError(domain: "a client error", code: 0)
        
        expect(sut, tocompleteWith: .failure(clientError), when: {
            client.complete(with: clientError)
        })
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, tocompleteWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code,data: anyData, at: index)
            })
        }
    }
    
    func test_loadImageDataFromURL_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        
        expect(sut, tocompleteWith: failure(.invalidData), when: {
            let emptyData = Data()
            client.complete(withStatusCode: 200, data: emptyData)
        })
    }
    
    func test_loadImageDataFromURL_deliversReceivedNonEmptyDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non empty data".utf8)
        
        expect(sut, tocompleteWith: .success(nonEmptyData), when: {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        })
    }
    
    func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
        let (sut, client) = makeSUT()
        let url = anyURL
        
        let task = sut.loadImageData(from: url, completion: { _ in } )
        XCTAssertTrue(client.cancelledURLs.isEmpty,"Expected no cancelled URL request until task is cancelled")
        
        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url],"Expected cancelled URL request after task is cancelled")
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)
        
        var capturedResults = [FeedImageDataLoader.Result]()
        sut?.loadImageData(from: anyURL) { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: anyData)
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK:  Helpers
    
    private func makeSUT(
        url: URL = anyURL,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RemoteFeedImageDataLoader,client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut, client)
    }
    
    private func expect(
        _ sut: RemoteFeedImageDataLoader,
        tocompleteWith expectedResult: FeedImageDataLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let url = URL(string: "https://a-given-url.com")!
        let exp = expectation(description: "Wait for load completion")
        
        sut.loadImageData(from: url) { receivedResult in
            switch(receivedResult,expectedResult) {
            case let (.success(receivedData),.success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case let (.failure(receivedError as NSError),.failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        .failure(error)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL,completion: ((HTTPClient.Result) -> Void))]()
        
        var requestedURLs: [URL] { messages.map{ $0.url } }
        private(set) var cancelledURLs = [URL]()
        
        func get(from url: URL, completion: @escaping ((HTTPClient.Result) -> Void)) -> HTTPClientTask {
            messages.append((url,completion))
            return Task { [weak self] in
                self?.cancelledURLs.append(url)
            }
        }
        
        func complete(with error: Error,at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int,data: Data,at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success((data,response)))
        }
        
        private struct Task: HTTPClientTask {
            let callback: (() -> Void)
            func cancel() { callback() }
        }
    }
}
