//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 18/01/2023.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.removeStub()
    }
    
    func test_getFromURL_performsGetRequestWithURL() {
        let url = anyURL
        
        let exp = expectation(description: "wait for request")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url){ _ in }
        
        wait(for: [exp], timeout: 0.01)
    }
    
    func test_cancelGetFromURLTask_cancelsURLRequest() {
        let receivedError = resultErrorFor(taskHandler: { $0.cancel() }) as? NSError
        
        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = anyNSError
        
        let receivedError = resultErrorFor((data: nil, response: nil, error: requestError)) as? NSError
        
        XCTAssertEqual(receivedError?.code , requestError.code)
        XCTAssertEqual(receivedError?.domain , requestError.domain)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData, response: nil, error: anyNSError)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse, error: anyNSError)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyHTTPURLResponse, error: anyNSError)))
        XCTAssertNotNil(resultErrorFor((data: anyData, response: nonHTTPURLResponse, error: anyNSError)))
        XCTAssertNotNil(resultErrorFor((data: anyData, response: anyHTTPURLResponse, error: anyNSError)))
        XCTAssertNotNil(resultErrorFor((data: anyData, response: nonHTTPURLResponse, error: nil)))
    }
    
    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        let data = anyData
        let response = anyHTTPURLResponse
        
        let receievedValues = resultValuesFor(data: data, response: response, error: nil)
        
        XCTAssertEqual(receievedValues?.data, data)
        XCTAssertEqual(receievedValues?.response.url, response.url)
        XCTAssertEqual(receievedValues?.response.statusCode, response.statusCode)
    }
    
    func test_getFromURL_succeedsWithEmpytDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse
        
        let receievedValues = resultValuesFor(data: nil, response: response, error: nil)
        
        let emptyData = Data()
        XCTAssertEqual(receievedValues?.data, emptyData)
        XCTAssertEqual(receievedValues?.response.url, response.url)
        XCTAssertEqual(receievedValues?.response.statusCode, response.statusCode)
    }
    
    // MARK:  Helper
    
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut,file: file,line: line)
        return sut
    }
    
    private func resultValuesFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (data: Data,response: HTTPURLResponse)? {
        let result = resultFor((data: data, response: response, error: error),file: file,line: line)
        
        switch result {
        case let .success((data, response)):
            return (data,response)
        default:
            XCTFail("Expected success ,got result \(result)instead")
            return nil
        }
    }
    
    private func resultErrorFor(
        _ values: (data: Data?,response: URLResponse?,error: Error?)? = nil,
        taskHandler: (HTTPClientTask) -> Void = { _ in },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Error? {
        let result = resultFor(values,taskHandler: taskHandler,file: file,line: line)
        
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Exptected failure ,got \(result) instead.",file: file,line: line)
            return nil
        }
    }
    
    private func resultFor(
        _ values: (data: Data?,response: URLResponse?,error: Error?)?,
        taskHandler: (HTTPClientTask) -> Void = { _ in },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HTTPClient.Result {
        values.map { URLProtocolStub.stub(data: $0, response: $1,error: $2)}
        
        let sut = makeSUT(file: file,line: line)
        
        let exp = expectation(description: "wait for completion")
        var receivedResult: HTTPClient.Result!
        taskHandler(sut.get(from: anyURL) { result in
            receivedResult = result
            exp.fulfill()
        })
        wait(for: [exp], timeout: 0.01)
        
        return receivedResult
    }
    
    private var nonHTTPURLResponse: URLResponse {
        URLResponse(url: anyURL, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private var anyHTTPURLResponse: HTTPURLResponse {
        HTTPURLResponse(url: anyURL, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
}
