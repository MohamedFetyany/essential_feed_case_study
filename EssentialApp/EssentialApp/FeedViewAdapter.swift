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
    
    typealias ResourceViewModel = Paginated<FeedImage>
    
    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data,WeakRefVirtualProxy<FeedImageCellController>>
    
    private weak var controller: ListViewController?
    private let imageLoader: ((URL) -> FeedImageDataLoader.Publisher)
    private let selection: ((FeedImage) -> Void)
    
    init(
        controller: ListViewController,
        imageLoader: @escaping ((URL) -> FeedImageDataLoader.Publisher),
        selection: @escaping ((FeedImage) -> Void)
    ) {
        self.controller = controller
        self.imageLoader = imageLoader
        self.selection = selection
    }
    
    func display(_ viewModel: Paginated<FeedImage>) {
        let feed: [CellController] = viewModel.items.map { model in
            let adapter = ImageDataPresentationAdapter(loader: { [imageLoader]  in imageLoader(model.url) })
            let view = FeedImageCellController(viewModel: FeedImagePresenter.map(model),delegate: adapter,selection: { [selection] in
                selection(model)
            })
            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: UIImage.tryMake
            )
            return CellController(id: model,view)
        }
        
        let loadMore = LoadMoreCellController(callback: {
            viewModel.loadMore?({ _ in })
        })
        let loadMoreSection = [CellController(id: UUID(), loadMore)]
        controller?.display(feed,loadMoreSection)
    }
}

extension UIImage {
    struct InvalidImageData: Error {}
    
    static func tryMake(_ data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw InvalidImageData()
        }
        
        return image
    }
}
