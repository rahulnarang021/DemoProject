//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by RN on 11/10/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import Foundation
public struct FeedViewModel: Equatable {
    public var isLoading: Bool
    
    public init(isLoading: Bool) {
        self.isLoading = isLoading
    }
}

public protocol LoadingView {
    func notifyLoad(viewModel: FeedViewModel)
}

public protocol FeedView {
    func loadFeed(withFeed feedItems:[FeedItem])
}

public class FeedPresenter {
    
    let feedView: FeedView
    let loadingView: LoadingView
    
    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Value for feed title")
    }

    public init(loadingView: LoadingView, feedView: FeedView) {
        self.loadingView = loadingView
        self.feedView = feedView
    }

    public func didStartLoadingFeed() {
       self.loadingView.notifyLoad(viewModel: FeedViewModel(isLoading: true))
    }
    
    public func didStopLoadingFeed() {
        self.loadingView.notifyLoad(viewModel: FeedViewModel(isLoading: false))
    }

    public func didLoadFeed(feeds: [FeedItem]) {
        self.feedView.loadFeed(withFeed: feeds)
    }

}
