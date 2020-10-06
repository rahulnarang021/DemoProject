//
//  FeedItemPresenter.swift
//  EssentialFeediOS
//
//  Created by rahul.narang on 27/09/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import Foundation
import EssentialFeed


protocol FeedImagePresenterProtocol {
    func loadImage(completion: ((Data?) -> Void)?)
    func loadFeed() -> FeedItem
    func cancelTask()
}

final class FeedItemPresenter: FeedImagePresenterProtocol {
    
    private let feedItem: FeedItem
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    
    init(feedItem: FeedItem, imageLoader: FeedImageDataLoader) {
        self.feedItem = feedItem
        self.imageLoader = imageLoader
    }
  
    func loadImage(completion: ((Data?) -> Void)?) {
        self.task = self.imageLoader.loadImageData(from: self.feedItem.imageURL) { result in
            let data = try? result.get()
            completion?(data)
        }
    }
    
    func loadFeed() -> FeedItem {
        return feedItem
    }

    func cancelTask() {
        task?.cancel()
        task = nil
    }
}
