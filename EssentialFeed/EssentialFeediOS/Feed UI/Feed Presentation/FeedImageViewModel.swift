//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 15/06/2023.
//

import Foundation
import EssentialFeed

class FeedImageViewModel<Image> {
    
    typealias Observer<T> = ((T) -> Void)
    
    private var task: FeedImageDataLoaderTask?
    
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private let imageTransformer: ((Data) -> Image?)
    
    init(model: FeedImage,imageLoader: FeedImageDataLoader,imageTransformer: @escaping ((Data) -> Image?)) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    var hasLocation: Bool {
        model.location != nil
    }
    
    var location: String? {
        model.location
    }
    
    var description: String? {
        model.description
    }
    
    var onImageLoad: Observer<Image>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    func loadImageData() {
        onShouldRetryImageLoadStateChange?(false)
        onImageLoadingStateChange?(true)
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            self?.handle(result)
        }
    }
    
    private func handle(_ result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChange?(true)
        }
        
        onImageLoadingStateChange?(false)
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
}

