//
//  RemoteLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 25/12/2023.
//

import XCTest
import EssentialFeed

class RemoteLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestedDataFromURL() {
        let (_,client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs,[url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs,[url,url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "test error", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnMapperError() throws {
        let (sut, client) = makeSUT(mapper: { _,_ in
            throw anyNSError
        })
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            client.complete(withStatusCode: 200,data: anyData)
        })
    }
    
    func test_load_deliversMappedResource() {
        let resource = "a resource"
        let (sut, client) = makeSUT(mapper: { data, _ in
            String(data: data, encoding: .utf8)!
        })
        
        expect(sut, toCompleteWith: .success(resource), when: {
            client.complete(withStatusCode: 200,data: Data(resource.utf8))
        })
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "https://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteLoader<String>? = RemoteLoader<String>(url: url, client: client,mapper: { _,_ in "any"})
        
        var capturedResults = [RemoteLoader<String>.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: anyData)
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK:  Helpers
    
    private func makeSUT(
        url: URL = URL(string: "https://a-url.com")!,
        mapper: @escaping RemoteLoader<String>.Mapper = { _,_ in "any" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) ->(sut: RemoteLoader<String>,client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteLoader<String>(url: url,client: client,mapper: mapper)
        
        trackForMemoryLeaks(sut,file: file,line: line)
        trackForMemoryLeaks(client,file: file,line: line)
        
        return (sut,client)
    }
    
    private func failure(_ error: RemoteLoader<String>.Error) -> RemoteLoader<String>.Result {
        .failure(error)
    }
    
    private func expect(
        _ sut: RemoteLoader<String>,
        toCompleteWith expectedResult: RemoteLoader<String>.Result,
        when action: (() -> Void),
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let exp = expectation(description: "wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult,expectedResult) {
                
            case let (.success(receivedItems),.success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems,file: file,line: line)
                
            case let (.failure(receivedError as RemoteLoader<String>.Error),.failure(expectedError as RemoteLoader<String>.Error)):
                XCTAssertEqual(receivedError, expectedError,file: file,line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) but got \(receivedResult) instead",file: file,line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 0.01)
    }
}
