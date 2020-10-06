//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by rahul.narang on 27/09/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import Foundation
import EssentialFeed

struct FeedViewModel {
    var isLoading: Bool
    
    init(isLoading: Bool) {
        self.isLoading = isLoading
    }
}
protocol LoadingView {
    func notifyLoad(viewModel: FeedViewModel)
}

protocol FeedView {
    func loadFeed(withFeed feedItems:[FeedItem])
}

final class FeedPresenter {
    
    let feedView: FeedView
    let loadingView: LoadingView
    
    static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self), comment: "Value for feed title")
    }
    
    init(loadingView: LoadingView, feedView: FeedView) {
        self.loadingView = loadingView
        self.feedView = feedView
    }
    
    func didStartLoadingFeed() {
        self.loadingView.notifyLoad(viewModel: FeedViewModel(isLoading: true))
    }
    
    func didStopLoadingFeed() {
        self.loadingView.notifyLoad(viewModel: FeedViewModel(isLoading: false))
    }

    func didLoadFeed(feeds: [FeedItem]) {
        self.feedView.loadFeed(withFeed: feeds)
    }
}
