//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Mohamed Ibrahim on 10/01/2023.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
