//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 07/01/2024.
//

import XCTest
import EssentialFeed

final class ImageCommentsLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        
        assertLocalizedKeyAndValueExist(in: bundle, table)
    }
}
