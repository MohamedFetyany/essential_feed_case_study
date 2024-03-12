//
//  ResourceErrorViewModel.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 27/07/2023.
//

import Foundation

public struct ResourceErrorViewModel {
    public let message: String?
    
    static var noError: ResourceErrorViewModel {
        ResourceErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> ResourceErrorViewModel {
        ResourceErrorViewModel(message: message)
    }
}
