//
//  FeedImagePresenter.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 26/06/2023.
//

import Foundation
import EssentialFeed

protocol FeedImageView<Image> {
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewModel<Image>)
}

class FeedImagePresenter<View: FeedImageView,Image> where View.Image == Image {
    
    private let view: View
    private let imageTransformer: ((Data) -> Image?)
    
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: true,
            shouldRetry: false)
        )
    }
    
    private struct InvalidImageDataError: Error {}
    
    func didStartLoadingImageData(with data: Data,for model: FeedImage) {
        guard let image = imageTransformer(data) else {
            didStartLoadingImageData(with: InvalidImageDataError(), for: model)
            return
        }
        
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: image,
            isLoading: false,
            shouldRetry: false)
        )
    }
    
    func didStartLoadingImageData(with error: Error,for model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: false,
            shouldRetry: true)
        )
    }
}
