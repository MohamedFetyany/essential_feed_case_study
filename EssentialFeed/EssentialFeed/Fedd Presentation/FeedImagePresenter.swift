//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 31/07/2023.
//

import Foundation

public final class FeedImagePresenter {
        
    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(description: image.description,location: image.location)
    }
}
