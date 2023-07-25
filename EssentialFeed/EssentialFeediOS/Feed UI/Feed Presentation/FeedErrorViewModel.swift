//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 25/07/2023.
//

import Foundation

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}
