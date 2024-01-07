//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 06/02/2023.
//

import Foundation

var anyURL: URL {
    URL(string: "https://any-url.com")!
}

var anyNSError: NSError {
    NSError(domain: "any error", code: 0)
}

var anyData: Data {
    Data("any data".utf8)
}

func makeItemsJson(_ items: [[String: Any]]) -> Data {
    let json = ["items": items]
    return try! JSONSerialization.data(withJSONObject: json)
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

extension Date {
    
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
    
    func adding(minutes: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .minute, value: minutes, to: self)!
    }
    
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}
