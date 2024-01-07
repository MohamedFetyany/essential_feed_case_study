//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 07/01/2024.
//

import XCTest
import EssentialFeed

class ImageCommentsPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }

    // MARK:  Helpers
    
    func localized(
        _ key: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> String {
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let table = "ImageComments"
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)",file: file,line: line)
        }
        return value
    }
}
