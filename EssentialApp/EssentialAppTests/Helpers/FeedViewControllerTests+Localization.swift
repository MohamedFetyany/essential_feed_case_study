//
//  FeedUIIntegrationTests+Localization.swift
//  EssentialFeediOSTests
//
//  Created by Mohamed Ibrahim on 13/07/2023.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

extension FeedUIIntegrationTests {
    
    var feedTitle: String {
        FeedPresenter.title
    }
    
    var loadError: String {
        LoadResourcePresenter<Any,DummyView>.loadError
    }
    
    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
}
