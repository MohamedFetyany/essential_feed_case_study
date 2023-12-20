//
//  FeedImageDataLoaderPresentation.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 18/07/2023.
//

import Foundation
import Combine
import EssentialFeed
import EssentialFeediOS

final class FeedImageDataLoaderPresentation<View: FeedImageView,Image>: FeedImageCellControllerDelegate where View.Image == Image {
    
    var presenter: FeedImagePresenter<View, Image>?
    
    private let model: FeedImage
    private let imageLoader: ((URL) -> FeedImageDataLoader.Publisher)
    private var cancellable: AnyCancellable?
    
    init(model: FeedImage, imageLoader: @escaping ((URL) -> FeedImageDataLoader.Publisher)) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        
        cancellable = imageLoader(model.url)
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self,model] completion in
                    switch completion {
                    case .finished: break
                        
                    case let .failure(error):
                        self?.presenter?.didFinishLoadingImageData(with: error, for: model)
                    }
                }, receiveValue: { [weak self,model] data in
                    self?.presenter?.didFinishLoadingImageData(with: data, for: model)
                })
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
    }
}

