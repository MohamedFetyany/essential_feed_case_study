//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Mohamed Ibrahim on 03/12/2023.
//

import UIKit
import CoreData
import Combine
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private let baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    
    private lazy var navigationController: UINavigationController = UINavigationController(
        rootViewController: FeedUIComposer.feedComposeWith(
            feedLoader: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeLocalImageLoaderWithRemoteFallback,
            selection: showComments
        )
    )
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        let localStoreURL = NSPersistentContainer
            .defaultDirectoryURL()
            .appendingPathComponent("feed-store.sqlite")
        return try! CoreDataFeedStore(storeURL: localStoreURL)
    }()
    
    convenience init(httpClient: HTTPClient,store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func configureWindow() {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>,Error> {
        let url = FeedEndpoint.get().url(baseURL: baseURL)
        
        return httpClient
            .getPublisher(from: url)
            .tryMap(FeedItemsMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map { items in
                Paginated(items: items,loadMorePublisher: self.makeRemoteLoadMoreLoader(items: items,last: items.last))
            }
            .eraseToAnyPublisher()
    }
    
    private func makeRemoteLoadMoreLoader(items: [FeedImage],last: FeedImage?) -> (() -> AnyPublisher<Paginated<FeedImage>, Error>)? {
        last.map { last in
            let url = FeedEndpoint.get(after: last).url(baseURL: baseURL)
            
            return  { [httpClient] in
                httpClient
                    .getPublisher(from: url)
                    .tryMap(FeedItemsMapper.map)
                    .map { newItems in
                        let allItems = items + newItems
                        return Paginated(items: allItems,loadMorePublisher: self.makeRemoteLoadMoreLoader(items: allItems,last: newItems.last) )
                    }
                    .eraseToAnyPublisher()
            }
        }
    }
    
    private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: { [httpClient] in
                httpClient.getPublisher(from: url)
                    .tryMap(FeedImageDataMapper.map)
                    .caching(to: localImageLoader, using: url)
            })
    }
    
    private func showComments(for image: FeedImage) {
        let url = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)
        let comments = CommentsUIComposer.commentsComposeWith(commentsLoader: makeRemoteCommentsLoader(url: url) )
        navigationController.pushViewController(comments, animated: true)
    }
    
    private func makeRemoteCommentsLoader(url: URL) -> () -> AnyPublisher<[ImageComment],Error> {
        { [httpClient] in
            httpClient
                .getPublisher(from: url)
                .tryMap(ImageCommentsMapper.map)
                .eraseToAnyPublisher()
        }
    }
}
