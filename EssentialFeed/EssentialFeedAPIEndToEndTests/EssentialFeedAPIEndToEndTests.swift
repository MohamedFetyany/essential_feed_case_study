//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Mohamed Ibrahim on 25/01/2023.
//

import XCTest
import EssentialFeed

final class EssentialFeedAPIEndToEndTests: XCTestCase {

    func test_endToEndTestServerGetFeedRequest_matchesFixedTestAccountData() {
        switch getFeedResult() {
        case let .success(feedImage)?:
            XCTAssertEqual(feedImage.count, 8,"Expected 8 image in  test account image feed")
            
            XCTAssertEqual(feedImage[0], expectedImage(at: 0))
            XCTAssertEqual(feedImage[1], expectedImage(at: 1))
            XCTAssertEqual(feedImage[2], expectedImage(at: 2))
            XCTAssertEqual(feedImage[3], expectedImage(at: 3))
            XCTAssertEqual(feedImage[4], expectedImage(at: 4))
            XCTAssertEqual(feedImage[5], expectedImage(at: 5))
            XCTAssertEqual(feedImage[6], expectedImage(at: 6))
            XCTAssertEqual(feedImage[7], expectedImage(at: 7))
            
        case let .failure(error)?:
            XCTFail("Expected successful feed result ,got \(error) instead")
            
        default:
            XCTFail("Expected successful feed result ,got no result instead")
        }
    }
    
    func test_endToEndTestServerGETFeedImageDataResult_matchesFixedTestAccountData() {
        switch getFeedImageDataResult() {
        case let .success(data):
            XCTAssertFalse(data.isEmpty,"Expected non-empty image data")
            
        case let .failure(error):
            XCTFail("Expected successful image data result, got \(error) instead")
            
            
        default:
            XCTFail("Expected successful image data result, got no result instead")
        }
        
    }
        
    // MARK: - Helpers
    
    private func getFeedResult(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> FeedLoader.Result? {
        let loader = RemoteFeedLoader(url: feedTestServerURL,client: ephemeralClient())
        trackForMemoryLeaks(loader, file: file, line: line)
        
        let exp = expectation(description: "Wait load completion")
        var receivedResult: FeedLoader.Result?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 7.0)
        
        return receivedResult
    }
    
    private func getFeedImageDataResult(file: StaticString = #filePath,line: UInt = #line) -> FeedImageDataLoader.Result? {
        let url = feedTestServerURL.appending(path: "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6/image")
        let loader = RemoteFeedImageDataLoader(client: ephemeralClient())
        trackForMemoryLeaks(loader,file: file,line: line)
        
        let exp = expectation(description: "Wait for load completion")
        var receviedResult: FeedImageDataLoader.Result?
        
        _ = loader.loadImageData(from: url, completion: { result in
            receviedResult = result
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 5.0)
        
        return receviedResult
    }
    
    private var feedTestServerURL: URL {
        URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
    }
    
    private func ephemeralClient(file: StaticString = #filePath,line: UInt = #line) -> HTTPClient {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        trackForMemoryLeaks(client,file: file,line: line)
        return client
    }
    
    private func expectedImage(at index: Int) -> FeedImage {
        FeedImage(
            id: id(at: index),
            description: description(at: index),
            location: location(at: index),
            url: imageURL(at: index))
    }
    
    private func id(at index: Int) -> UUID {
        UUID(uuidString: [
            "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
            "BA298A85-6275-48D3-8315-9C8F7C1CD109",
            "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
            "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
            "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
            "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
            "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
            "F79BD7F8-063F-46E2-8147-A67635C3BB01"
        ][index])!
    }
    
    private func description(at index: Int) -> String? {
        [
            "Description 1",
            nil,
            "Description 3",
            nil,
            "Description 5",
            "Description 6",
            "Description 7",
            "Description 8"
        ][index]
    }
    
    private func location(at index: Int) -> String? {
        [
            "Location 1",
            "Location 2",
            nil,
            nil,
            "Location 5",
            "Location 6",
            "Location 7",
            "Location 8"
        ][index]
    }
    
    private func imageURL(at index: Int) -> URL {
        URL(string: "https://url-\(index+1).com")!
    }
}
