//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 31/07/2023.
//

import Foundation

public struct FeedImageViewModel {
    public let description: String?
    public let location: String?
    
    public var hasLocation: Bool {
        location != nil
    }
}
