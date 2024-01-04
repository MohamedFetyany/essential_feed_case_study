//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 18/07/2023.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: ResourceView {
    
    typealias ResourceViewModel = FeedViewModel
    
    private typealias FeedImageDataLoaderPresentationAdapter = LoadResourcePresentationAdapter<Data,WeakRefVirtualProxy<FeedImageCellController>>
    
    private weak var controller: FeedViewController?
    private let imageLoader: ((URL) -> FeedImageDataLoader.Publisher)
    
    init(controller: FeedViewController, imageLoader: @escaping ((URL) -> FeedImageDataLoader.Publisher)) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapter(loader: { [imageLoader]  in imageLoader(model.url) })
            let view = FeedImageCellController(viewModel: FeedImagePresenter.map(model),delegate: adapter)
            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: { data in
                    guard let image = UIImage(data: data) else {
                        throw InvalidImageData()
                    }
                    
                    return image
                }
            )
            return view
        })
    }
}

private class InvalidImageData: Error {}
