//
//  ListSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Mohamed Ibrahim on 08/01/2024.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class ListSnapshotTests: XCTestCase {
    
    func test_emptyList() {
        let sut = makeSUT()
        
        sut.display(emptyList())
        
        assert(snapshot: sut.snapshot(for: .iphone(style: .light)), named: "EMPTY_LIST_light")
        assert(snapshot: sut.snapshot(for: .iphone(style: .dark)), named: "EMPTY_LIST_dark")
    }
    
    func test_listWithError() {
        let sut = makeSUT()
        
        sut.display(.error(message: "This a\nmulti-line\nerror message"))
        
        assert(snapshot: sut.snapshot(for: .iphone(style: .light)),named: "LIST_WITH_ERROR_light")
        assert(snapshot: sut.snapshot(for: .iphone(style: .dark)),named: "LIST_WITH_ERROR_dark")
        assert(snapshot: sut.snapshot(for: .iphone(style: .light,contentSize: .extraExtraExtraLarge)),named: "LIST_WITH_ERROR_light_extraExtraExtraLarge")
    }
    
    // MARK:  Helpers
    
    private func makeSUT() -> ListViewController {
        let sut = ListViewController()
        sut.loadViewIfNeeded()
        sut.tableView.separatorStyle = .none
        sut.tableView.showsVerticalScrollIndicator = false
        sut.tableView.showsHorizontalScrollIndicator = false
        return sut
    }
    
    private func emptyList() -> [CellController] { [] }
    
}
