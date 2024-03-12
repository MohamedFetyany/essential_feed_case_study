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
    
    func test_mape_createsViewModels() {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")
        
        let comments = [
            ImageComment(id: UUID(), message: "a message", createdAt: now.adding(minutes: -5,calendar: calendar), username: "a username"),
            ImageComment(id: UUID(), message: "anthor message", createdAt: now.adding(days: -1,calendar: calendar), username: "anthor username")
        ]
        
        let viewModels = ImageCommentsPresenter.map(comments,currentDate: now,calendar: calendar, locale: locale)
        
        XCTAssertEqual(viewModels.comments, [
            ImageCommentViewModel(message: "a message",date: "5 minutes ago",username: "a username"),
            ImageCommentViewModel(message: "anthor message",date: "1 day ago",username: "anthor username")
        ])
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
