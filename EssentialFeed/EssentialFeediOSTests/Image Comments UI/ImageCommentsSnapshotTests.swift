//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Mohamed Ibrahim on 08/01/2024.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class ImageCommentsSnapshotTests: XCTestCase {
    
    func test_listWithComments() {
        let sut = makeSUT()
        
        sut.display(comments())
        
        assert(snapshot: sut.snapshot(for: .iphone(style: .light)), named: "IMAGE_COMMENTS_light")
        assert(snapshot: sut.snapshot(for: .iphone(style: .dark)), named: "IMAGE_COMMENTS_dark")
    }
    
    // MARK:  Helpers
    
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let sut = storyboard.instantiateInitialViewController() as! ListViewController
        sut.loadViewIfNeeded()
        sut.tableView.showsVerticalScrollIndicator = false
        sut.tableView.showsHorizontalScrollIndicator = false
        return sut
    }
    
    private func comments() -> [CellController] {
        commentControllers().map { CellController($0) }
    }
        
    private func commentControllers() -> [ImageCommentCellController] {
        [
            ImageCommentCellController(
                viewModel: ImageCommentViewModel(
                    message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                    date: "100 years ago",
                    username: "a long long long long username"
                )
            ),
            
            ImageCommentCellController(
                viewModel: ImageCommentViewModel(
                    message: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                    date: "10 hours ago",
                    username: "a username"
                )
            ),
            ImageCommentCellController(
                viewModel: ImageCommentViewModel(
                    message: "nice",
                    date: "1 minute ago",
                    username: "a."
                )
            ),
        ]
    }
}
