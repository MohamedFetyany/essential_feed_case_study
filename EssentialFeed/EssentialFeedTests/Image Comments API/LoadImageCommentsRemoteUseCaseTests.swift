//
//  LoadImageCommentsRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 24/12/2023.
//

import XCTest
import EssentialFeed

class LoadImageCommentsRemoteUseCaseTests: XCTestCase {
    
    func test_load_deliversErrorOnNon2xxHTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199,150,300,400,500]
        
        samples.enumerated().forEach { index,code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemsJson([])
                client.complete(withStatusCode: code,data: json,at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn2xxHTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        let samples = [200,201,250,280,299]
        
        samples.enumerated().forEach { index,code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let invalidJSON = Data("invalid json".utf8)
                client.complete(withStatusCode: code,data: invalidJSON,at: index)
            })
        }
    }
    
    func test_load_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        let samples = [200,201,250,280,299]
        
        samples.enumerated().forEach { index,code in
            expect(sut, toCompleteWith: .success([]), when: {
                let emptyJsonList = makeItemsJson([])
                client.complete(withStatusCode: code,data: emptyJsonList,at: index)
            })
        }
    }
    
    func test_load_deliversItemsOn2xxHTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            message: "a message",
            createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
            username: "a username"
        )
        let item2 = makeItem(
            id: UUID(),
            message: "anthor message",
            createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
            username: "anthor username"
        )
     
        let items = [item1.model,item2.model]
        
        let samples = [200,201,250,280,299]
        
        samples.enumerated().forEach { index,code in
            expect(sut, toCompleteWith: .success(items), when: {
                let json = makeItemsJson([item1.json,item2.json])
                client.complete(withStatusCode: code,data: json,at: index)
            })
        }
    }
    
    // MARK:  Helpers
    
    private func makeSUT(
        url: URL = URL(string: "https://a-url.com")!,
        file: StaticString = #filePath,
        line: UInt = #line
    ) ->(sut: RemoteImageCommentsLoader,client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(url: url,client: client)
        
        trackForMemoryLeaks(sut,file: file,line: line)
        trackForMemoryLeaks(client,file: file,line: line)
        
        return (sut,client)
    }
    
    private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
        .failure(error)
    }
    
    private func makeItemsJson(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func makeItem(
        id: UUID,
        message: String,
        createdAt: (date: Date,ios8601String: String),
        username: String
    ) -> (model: ImageComment,json: [String: Any]) {
        let item = ImageComment(
            id: id,
            message: message,
            createdAt: createdAt.date,
            username: username
        )
        
        let json:  [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.ios8601String,
            "author": [
                "username": username
            ]
        ]
        
        return (item,json)
    }
    
    private func expect(
        _ sut: RemoteImageCommentsLoader,
        toCompleteWith expectedResult: RemoteImageCommentsLoader.Result,
        when action: (() -> Void),
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        let exp = expectation(description: "wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult,expectedResult) {
                
            case let (.success(receivedItems),.success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems,file: file,line: line)
                
            case let (.failure(receivedError as RemoteImageCommentsLoader.Error),.failure(expectedError as RemoteImageCommentsLoader.Error)):
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
