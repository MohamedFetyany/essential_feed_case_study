//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Mohamed Ibrahim on 16/07/2023.
//

import XCTest
import EssentialFeed

final class FeedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        
        assertLocalizedKeyAndValueExist(in: bundle, table)
    }
}
