//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Mohamed Ibrahim on 17/08/2023.
//

import Foundation
import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {

    enum Message: Equatable {
        case retrieve(dataFor: URL)
        case insert(data: Data,for: URL)
    }
    
    private var retrievalcompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
    private var insertioncompletions = [(FeedImageDataStore.InsertionResult) -> Void]()

    private(set) var receivedMessages = [Message]()
    
    func retreive(dataForUrl url: URL,completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        receivedMessages.append(.retrieve(dataFor: url))
        retrievalcompletions.append(completion)
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        receivedMessages.append(.insert(data: data, for: url))
        insertioncompletions.append(completion)
    }
    
    func completeRetrieval(with error: Error,at index: Int = 0) {
        retrievalcompletions[index](.failure(error))
    }
    
    func completeRetrieval(with data: Data?,at index: Int = 0) {
        retrievalcompletions[index](.success(data))
    }
    
    func completeInsertion(with error: Error,at index: Int = 0) {
        insertioncompletions[index](.failure(error))
    }
}
