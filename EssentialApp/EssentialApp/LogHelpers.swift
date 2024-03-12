//
//  LogHelpers.swift
//  EssentialApp
//
//  Created by Mohamed Ibrahim on 30/01/2024.
//

import os
import UIKit
import Combine
import EssentialFeed

extension Publisher {
    
    func logCacheMisses(url: URL,logger: Logger) -> AnyPublisher<Output,Failure> {
        return handleEvents(receiveCompletion: { result in
            if case .failure = result {
                logger.trace("Cache miss for url \(url)")
            }
        }).eraseToAnyPublisher()
    }
    
    func logErrors(url: URL,logger: Logger) -> AnyPublisher<Output,Failure> {
        return handleEvents(receiveCompletion: { result in
            if case let .failure(error) = result {
                logger.trace("Failed to load url \(url) with error: \(error.localizedDescription)")
            }
        }).eraseToAnyPublisher()
    }
    
    func logElapsedTime(url: URL,logger: Logger) -> AnyPublisher<Output,Failure> {
        var startTime = CACurrentMediaTime()
        return handleEvents(
            receiveSubscription: {  _ in
                logger.trace("Started loading url: \(url)")
                startTime = CACurrentMediaTime()
            },
            receiveCompletion: { result in
                let elapsed = CACurrentMediaTime() - startTime
                logger.trace("Finished loading url: \(url) in \(elapsed) seconds")
            }).eraseToAnyPublisher()
    }
}

private class HTTPClientProfilingDecorator: HTTPClient {
    
    private let decoratee: HTTPClient
    private let logger: Logger
    
    init(decoratee: HTTPClient, logger: Logger) {
        self.decoratee = decoratee
        self.logger = logger
    }
    
    func get(from url: URL, completion: @escaping ((HTTPClient.Result) -> Void)) -> HTTPClientTask {
        logger.trace("Started loading url: \(url)")
        
        let startTime = CACurrentMediaTime()
        return decoratee.get(from: url) { [logger] result in
            if case let .failure(error) = result {
                logger.trace("Failed to load url \(url) with error: \(error.localizedDescription)")
            }
            
            let elapsed = CACurrentMediaTime() - startTime
            logger.trace("Finished loading url: \(url) in \(elapsed) seconds")
            
            completion(result)
        }
    }
}

