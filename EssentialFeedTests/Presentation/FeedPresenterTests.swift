//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by RN on 11/10/20.
//  Copyright © 2020 Oravel Stays Pvt Ltd. All rights reserved.
//

import XCTest
import EssentialFeed

class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotPassAnyMessageToView() {
        let sut = makeSUT()
        XCTAssertTrue(sut.feedView.loadFeedMessages.isEmpty, "Feed View messages should be empty")
        XCTAssertTrue(sut.feedView.loadFeedMessages.isEmpty, "Load Feed messages should be empty")
    }
    
    func test_didStartLoad_shouldPassLoadMessageToLoadingView() {
        let sut = makeSUT()
        sut.presenter.didStartLoadingFeed()
        XCTAssertEqual(sut.loadingView.loadMessages, [FeedViewModel(isLoading: true)])
    }
    
    func test_didStopLoad_shouldPassLoadMessageToLoadingView() {
        let sut = makeSUT()
        sut.presenter.didStopLoadingFeed()
        XCTAssertEqual(sut.loadingView.loadMessages, [FeedViewModel(isLoading: false)])
    }
    
    func test_didLoadFeed_shouldPassFeedsToFeedView() {
        let sut = makeSUT()
        let item1 = FeedItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "https://a-image-url.jpeg")!)
        let item2 = FeedItem(id: UUID(), description: "a description", location: nil, imageURL: URL(string: "https://a-image-url.jpeg")!)

        let items = [item1, item2]
        sut.presenter.didLoadFeed(feeds: items)
        
        XCTAssertEqual(sut.feedView.loadFeedMessages, [items])
    }
    
    func test_FeedPresenter_titleIsCorrect() {
        let title = FeedPresenter.title
        XCTAssertEqual(title, localizedString(for: "FEED_VIEW_TITLE"))
    }
    
    func localizedString(for key: String, file: StaticString = #file, line: UInt8 = #line) -> String {
        let bundle = Bundle(for: FeedPresenter.self)
        let value = NSLocalizedString(key, tableName: "Feed", bundle: bundle, comment: "Localized value")
        if(value == key) {
            XCTFail("Key:\(key) should not be equal to value:\(value)")
        }
        return value
    }
    // MARK: - Make SUT
    func makeSUT() -> (presenter: FeedPresenter, loadingView: ViewSpy, feedView: ViewSpy){
        let loadingView = ViewSpy()
        let feedView = ViewSpy()
        let presenter = FeedPresenter(loadingView: loadingView, feedView: feedView)
        return (presenter: presenter, loadingView: loadingView, feedView: feedView)
    }
}

final class ViewSpy: FeedView, LoadingView {
    
    var loadMessages: [FeedViewModel] = []
    var loadFeedMessages: [[FeedItem]] = []
    
    func notifyLoad(viewModel: FeedViewModel) {
        loadMessages.append(viewModel)
    }
    
    func loadFeed(withFeed feedItems:[FeedItem]) {
        loadFeedMessages.append(feedItems)
    }
    
}
