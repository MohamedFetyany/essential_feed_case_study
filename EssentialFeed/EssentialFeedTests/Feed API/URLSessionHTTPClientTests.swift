//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 18/01/2023.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequest()
    }
    
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.stopInterceptingRequest()
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
        let url = anyURL
        let exp = expectation(description: "Wait for request")
        
        let task = makeSUT().get(from: url) { result in
            switch result {
            case let .failure(error as NSError) where error.code == URLError.cancelled.rawValue:
                break
                
            default:
                XCTFail("Expected cancels result, got \(result) instead")
            }
            exp.fulfill()
        }
        
        task.cancel()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = anyNSError
        
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError) as? NSError
        
        XCTAssertEqual(receivedError?.code , requestError.code)
        XCTAssertEqual(receivedError?.domain , requestError.domain)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: anyNSError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: anyNSError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse, error: anyNSError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTPURLResponse, error: anyNSError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: anyHTTPURLResponse, error: anyNSError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTPURLResponse, error: nil))
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
        let sut = URLSessionHTTPClient()
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
        let result = resultFor(data: data, response: response, error: error,file: file,line: line)
        
        switch result {
        case let .success((data, response)):
            return (data,response)
        default:
            XCTFail("Expected success ,got result \(result)instead")
            return nil
        }
    }

    private func resultErrorFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Error? {
        let result = resultFor(data: data, response: response, error: error,file: file,line: line)
        
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Exptected failure ,got \(result) instead.",file: file,line: line)
            return nil
        }
    }
    
    private func resultFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HTTPClient.Result {
        URLProtocolStub.stub(data: data, response: response,error: error)
        
        let sut = makeSUT(file: file,line: line)
        
        let exp = expectation(description: "wait for completion")
        var receivedResult: HTTPClient.Result!
        sut.get(from: anyURL) { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 0.01)
        
        return receivedResult
    }
    
    private var nonHTTPURLResponse: URLResponse {
        URLResponse(url: anyURL, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private var anyHTTPURLResponse: HTTPURLResponse {
        HTTPURLResponse(url: anyURL, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func stub(data: Data?,response: URLResponse?,error: Error?) {
            stub = Stub(data: data,response: response,error: error)
        }
        
        static func startInterceptingRequest() {
            URLProtocolStub.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocolStub.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let requestObserver = URLProtocolStub.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }
            
            guard  let stub = URLProtocolStub.stub else { return }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }

}
