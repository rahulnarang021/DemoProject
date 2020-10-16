//
//  FeedComposer.swift
//  EssentialFeediOS
//
//  Created by rahul.narang on 27/09/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import Foundation
import EssentialFeed

final public class FeedUIComposer {
    public class func makeFeedViewController(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let refreshController = RefreshViewController()
        
        let controller = FeedViewController.initializeController(refreshController: refreshController)
        
        let adapter = FeedAdapter(controller: controller, imageLoader: MainQueueDecorator(decoratee: imageLoader))
        
        let feedPresenter: FeedPresenter = FeedPresenter(loadingView: WeakProxy(refreshController), feedView: adapter)
        
        controller.title = FeedPresenter.title
        
        let decorator: FeedLoader = MainQueueDecorator(decoratee: feedLoader)
        refreshController.presenter = FeedViewAdapter(feedLoader: decorator, presenter: feedPresenter)
        
        return controller
    }
}

final class MainQueueDecorator<T> {
    var decoratee: T
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(_ completion: @escaping () -> Void) {
        if Thread.isMainThread {
            completion()
        } else {
            DispatchQueue.main.async(execute: completion)
        }
    }
}

extension MainQueueDecorator: FeedLoader where T == FeedLoader {
    
    func load(completion: @escaping (FeedLoaderResult) -> Void) {
        decoratee.load {[weak self] feed in
            self?.dispatch {
                completion(feed)
            }
        }
    }
}

extension MainQueueDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url) {[weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}

final class WeakProxy<T: AnyObject> {
    weak var weakRef: T?
    
    init(_ ref: T) {
        self.weakRef = ref
    }
}

extension WeakProxy: LoadingView where T: LoadingView {
    func notifyLoad(viewModel: FeedViewModel) {
        weakRef?.notifyLoad(viewModel: viewModel)
    }
}

final class FeedAdapter: FeedView {
    weak var controller: FeedViewController?
    var imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func loadFeed(withFeed feedItems: [FeedItem]) {
        controller?.tableModel = feedItems.map {feed in
            let feedPresenter = FeedItemPresenter(feedItem: feed, imageLoader: imageLoader)
            return FeedItemController(feedImagePresenter: feedPresenter) }
    }
}


final class FeedViewAdapter: FeedLoadPresenter {
    let feedLoader: FeedLoader
    let presenter: FeedPresenter
    init(feedLoader: FeedLoader, presenter: FeedPresenter) {
        self.feedLoader = feedLoader
        self.presenter = presenter
    }
    
    func load() {
        presenter.didStartLoadingFeed()
        feedLoader.load {[weak self] result in
            if let feeds = try? result.get() {
                self?.presenter.didLoadFeed(feeds: feeds)
            }
            self?.presenter.didStopLoadingFeed()
        }
    }
}
